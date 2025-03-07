# Spring Boot 3 Observability with Grafana Stack

## Running the project

To run the project, you need to have Docker and Docker Compose installed. Then, run the following command:

```docker compose up -d```

Run Loan Service Application

```cd loan-service```

```mvn clean spring-boot:run```

Run Fraud Detection Service Application

```cd fraud-detection-service```

```mvn clean spring-boot:run```

## Accessing the services

1. Grafana: http://localhost:3000
2. Prometheus: http://localhost:9090
3. Tempo: http://localhost:3110
4. Loki: http://localhost:3100
5. Loans: http://localhost:8080/api/loans
6. Fraud: http://localhost:8081/api/frauds/check?customerId=105

## Project Overview

![Observability](img/observability.png "Observability")
