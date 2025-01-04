CREATE TABLE fraud_records
(
    id            bigint      NOT NULL,
    fraud_record_id VARCHAR(36) NOT NULL,
    customer_id     INT         NOT NULL,
    PRIMARY KEY (id)
);
