# Spring Boot Observability with Grafana Stack

Two Spring Boot services — `loan-service` and `fraud-detection-service` — instrumented with Micrometer and
wired into the Grafana stack: metrics to Prometheus, traces to Tempo (Zipkin protocol), logs to Loki, all
dashboarded in Grafana.

## Requirements

| | |
|---|---|
| JDK | **25** (`java.version` is `25` in every module; bytecode is class-file major version 69) |
| Spring Boot | 4.1.1 |
| Build | Maven — use the bundled wrapper `./mvnw` |
| Runtime deps | Docker + Docker Compose (MySQL and the Grafana stack) |
| Tests | Testcontainers 2.x — needs a running Docker daemon |

Point `JAVA_HOME` at a JDK 25 install before building, e.g.:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 25)   # macOS
java -version                                      # should report 25.x
```

## Running the project

Start the infrastructure (MySQL, Tempo, Loki, Prometheus, Grafana):

```bash
docker compose up -d
```

Then run each service. From the repository root:

```bash
./mvnw -pl loan-service spring-boot:run
./mvnw -pl fraud-detection-service spring-boot:run
```

Or build once and run the jars:

```bash
./mvnw clean package
java -jar loan-service/target/loan-service-0.0.1-SNAPSHOT.jar
java -jar fraud-detection-service/target/fraud-detection-service-0.0.1-SNAPSHOT.jar
```

Both services run Flyway migrations on startup, so MySQL must be up first.

## Building and testing

```bash
./mvnw clean verify        # compile + run the Testcontainers integration tests
./mvnw clean package -DskipTests
```

The tests start their own MySQL containers via Testcontainers, so Docker must be running — they do **not**
use the `docker compose` MySQL.

## Accessing the services

| Service | URL |
|---|---|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Loki | http://localhost:3100 |
| Tempo | in-network only — Grafana reaches it at `http://tempo:3200`; the Zipkin ingest port is http://localhost:9411 |
| MySQL | `localhost:33081` (user `yu71` / password `53cret`) |
| Loan Service | http://localhost:8080 |
| Fraud Detection Service | http://localhost:8081 |

### Endpoints

```bash
# List loans
curl http://localhost:8080/api/loans

# Apply for a loan (calls fraud-detection-service behind the scenes)
curl -X POST http://localhost:8080/api/loans \
  -H 'Content-Type: application/json' \
  -d '{"customerName":"Yuji","customerId":101,"amount":1500}'

# Fraud check, called directly
curl "http://localhost:8081/api/frauds/check?customerId=105"

# Actuator
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/prometheus
```

## Observability

* **Metrics** — each service exposes `/actuator/prometheus`; Prometheus scrapes both via
  `host.docker.internal` (see `docker/prometheus/prometheus.yml`).
* **Traces** — Micrometer Tracing with the Brave bridge, reported over the Zipkin protocol to Tempo on
  port 9411. Sampling is set to 1.0, and the trace ID propagates from `loan-service` into
  `fraud-detection-service` on the outgoing `RestTemplate` call.
* **Logs** — Loki4j pushes to `http://localhost:3100/loki/api/v1/push` with the labels `application`,
  `host` and `level`. Every line carries `[application,traceId,spanId]` via
  `logging.pattern.correlation`, so a trace in Tempo can be pivoted to its logs in Loki.

## Project Overview

![Observability](img/observability.png "Observability")
