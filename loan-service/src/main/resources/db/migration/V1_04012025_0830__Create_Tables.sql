CREATE TABLE loans
(
    id           bigint AUTO_INCREMENT PRIMARY KEY,
    loan_id       VARCHAR(36)  NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_id   INT          NOT NULL,
    amount       DECIMAL(10, 2) NOT NULL,
    loan_status   VARCHAR(50)  NOT NULL
);
