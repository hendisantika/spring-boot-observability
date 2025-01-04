CREATE TABLE fraud_records
(
    id            bigint      NOT NULL,
    fraudrecordid VARCHAR(36) NOT NULL,
    customerid    INT         NOT NULL,
    PRIMARY KEY (id)
);
