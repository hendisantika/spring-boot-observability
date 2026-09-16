#!/usr/bin/env bash
#
# Drives both services, then proves the telemetry actually arrived:
# metrics in Prometheus, logs in Loki, and the matching trace in Tempo.
#
#   ./scripts/smoke-test.sh            # default 20 iterations
#   ./scripts/smoke-test.sh 50         # more traffic
#
# Everything is overridable by environment variable, e.g.
#   LOAN_URL=http://loan.jvm.my.id ./scripts/smoke-test.sh
#
# Prerequisites: `docker compose up -d` and both services running.

set -uo pipefail

ITERATIONS="${1:-20}"

LOAN_URL="${LOAN_URL:-http://localhost:8080}"
FRAUD_URL="${FRAUD_URL:-http://localhost:8081}"
LOKI_URL="${LOKI_URL:-http://localhost:3100}"
TEMPO_URL="${TEMPO_URL:-http://localhost:3200}"
PROM_URL="${PROM_URL:-http://localhost:9090}"
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$*"; }

sleep_s() { python3 -c "import time,sys; time.sleep(float(sys.argv[1]))" "$1" 2>/dev/null || command sleep "$1"; }

FAILED=0
fail() { red "  FAIL  $*"; FAILED=$((FAILED + 1)); }
pass() { green "  ok    $*"; }

# curl with a short timeout; prints the HTTP status only
status() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$@"; }

# Poll a URL until it returns 200. Loki and Tempo answer /ready with 503 for
# the first ~15s after start, so a single shot would fail on a stack that is
# merely still warming up.
wait_200() {
  local url="$1" tries="${2:-${WAIT_TRIES:-12}}" code=""
  for _ in $(seq 1 "$tries"); do
    code=$(status "$url")
    [ "$code" = "200" ] && { printf '%s' "$code"; return 0; }
    sleep_s 5
  done
  printf '%s' "$code"
  return 1
}

# ---------------------------------------------------------------- preflight

head_ "1. Preflight"

for pair in "loan-service|$LOAN_URL/actuator/health" \
            "fraud-detection-service|$FRAUD_URL/actuator/health" \
            "loki|$LOKI_URL/ready" \
            "tempo|$TEMPO_URL/ready" \
            "prometheus|$PROM_URL/-/ready"; do
  name="${pair%%|*}"; url="${pair##*|}"
  if code=$(wait_200 "$url"); then
    pass "$name reachable"
  else
    fail "$name unreachable ($url returned ${code:-no response})"
  fi
done

if [ "$FAILED" -gt 0 ]; then
  red ""
  red "Preflight failed. Start the stack and the services first:"
  dim "  docker compose up -d"
  dim "  java -jar loan-service/target/loan-service-0.0.1-SNAPSHOT.jar &"
  dim "  java -jar fraud-detection-service/target/fraud-detection-service-0.0.1-SNAPSHOT.jar &"
  exit 1
fi

# ------------------------------------------------------------------ traffic

head_ "2. Generating traffic ($ITERATIONS iterations)"

# Customer 104 is approved and 103 is rejected by the fraud service, so the
# run produces both branches rather than only the happy path.
for _ in $(seq 1 "$ITERATIONS"); do
  curl -s -o /dev/null --max-time 10 "$LOAN_URL/api/loans"
  curl -s -o /dev/null --max-time 10 -X POST "$LOAN_URL/api/loans" \
    -H 'Content-Type: application/json' \
    -d '{"customerName":"Smoke Approved","customerId":104,"amount":150}'
  curl -s -o /dev/null --max-time 10 -X POST "$LOAN_URL/api/loans" \
    -H 'Content-Type: application/json' \
    -d '{"customerName":"Smoke Rejected","customerId":103,"amount":9000}'
  curl -s -o /dev/null --max-time 10 "$FRAUD_URL/api/frauds/check?customerId=101"
done
# One 404 so there is a non-2xx span to look at in Tempo.
curl -s -o /dev/null --max-time 10 "$LOAN_URL/api/does-not-exist"
pass "sent $((ITERATIONS * 4 + 1)) requests across both services"

head_ "3. Waiting for ingestion"
dim "  Loki batches, Prometheus scrapes every 15s, Tempo flushes — giving it 45s"
sleep_s 45

# --------------------------------------------------------------- prometheus

head_ "4. Prometheus"

for app in loan-service fraud-detection-service; do
  n=$(curl -s --max-time 10 --get "$PROM_URL/api/v1/query" \
        --data-urlencode "query=http_server_requests_seconds_count{application=\"$app\"}" \
      | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["data"]["result"]))' 2>/dev/null)
  if [ "${n:-0}" -gt 0 ]; then pass "$app: $n http_server_requests series"; else fail "$app: no http_server_requests series"; fi
done

# --------------------------------------------------------------------- loki

head_ "5. Loki"

now_ns=$(python3 -c 'import time; print(int(time.time()*1e9))')
from_ns=$(python3 -c 'import time; print(int((time.time()-900)*1e9))')

TRACE_ID=""
for app in loan-service fraud-detection-service; do
  body=$(curl -s --max-time 15 --get "$LOKI_URL/loki/api/v1/query_range" \
          --data-urlencode "query={application=\"$app\"}" \
          --data-urlencode "start=$from_ns" --data-urlencode "end=$now_ns" \
          --data-urlencode "limit=300")
  count=$(printf '%s' "$body" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
    print(sum(len(s["values"]) for s in d["data"]["result"]))
except Exception:
    print(0)' 2>/dev/null)
  if [ "${count:-0}" -gt 0 ]; then pass "$app: $count log lines"; else fail "$app: no log lines"; fi

  # Pull a traceId out of the [app,traceId,spanId] correlation pattern.
  # Matched on the ,<32hex>,<16hex>] tail only: no quotes in the pattern, so
  # nothing here depends on shell escaping inside the embedded Python.
  if [ -z "$TRACE_ID" ]; then
    TRACE_ID=$(printf '%s' "$body" | python3 -c 'import json,re,sys
try:
    d=json.load(sys.stdin)
except Exception:
    raise SystemExit
for s in d["data"]["result"]:
    for _, line in s["values"]:
        m=re.search(r",([0-9a-f]{32}),[0-9a-f]{16}\]", line)
        if m:
            print(m.group(1)); raise SystemExit' 2>/dev/null)
  fi
done

if [ -n "$TRACE_ID" ]; then
  pass "extracted traceId from a log line: $TRACE_ID"
else
  fail "no traceId found in any log line (is logging.pattern.correlation set?)"
fi

# -------------------------------------------------------------------- tempo

head_ "6. Tempo"

if [ -n "$TRACE_ID" ]; then
  trace=$(curl -s --max-time 15 "$TEMPO_URL/api/traces/$TRACE_ID")
  services=$(printf '%s' "$trace" | python3 -c 'import json,sys
try:
    d=json.load(sys.stdin)
except Exception:
    raise SystemExit
names=set()
spans=0
for b in d.get("batches", []):
    for a in b.get("resource", {}).get("attributes", []):
        if a.get("key")=="service.name":
            names.add(a["value"].get("stringValue"))
    for ss in b.get("scopeSpans", []):
        spans += len(ss.get("spans", []))
print(",".join(sorted(n for n in names if n)) + "|" + str(spans))' 2>/dev/null)

  names="${services%%|*}"; spans="${services##*|}"
  if [ -n "$names" ]; then
    pass "trace found in Tempo: ${spans} span(s) across [${names}]"
    case "$names" in
      *loan-service*fraud-detection-service*|*fraud-detection-service*loan-service*)
        pass "trace spans BOTH services — context propagated across the HTTP call" ;;
      *)
        dim "  note: this trace only touches [$names]; a POST /api/loans trace spans both" ;;
    esac
  else
    fail "traceId $TRACE_ID not found in Tempo"
  fi
else
  dim "  skipped (no traceId to look up)"
fi

# ------------------------------------------------------------------ summary

head_ "7. Where to look in Grafana"
dim "  Dashboard   $GRAFANA_URL/d/sOae4vCnk"
dim "  Explore/Loki  $GRAFANA_URL/explore?left=%7B%22datasource%22:%22loki%22%7D"
dim "                query: {application=\"loan-service\"}"
if [ -n "$TRACE_ID" ]; then
  dim "  Trace       $GRAFANA_URL/explore?left=%7B%22datasource%22:%22tempo%22%7D"
  dim "                traceId: $TRACE_ID"
fi

printf '\n'
if [ "$FAILED" -eq 0 ]; then
  green "All checks passed — metrics, logs and traces are all arriving."
  exit 0
else
  red "$FAILED check(s) failed."
  exit 1
fi
