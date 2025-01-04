CREATE TABLE loans
(
    id           bigint AUTO_INCREMENT PRIMARY KEY,
    loanid       VARCHAR(36)    NOT NULL,
    customername VARCHAR(255)   NOT NULL,
    customerid   INT            NOT NULL,
    amount       DECIMAL(10, 2) NOT NULL,
    loanstatus   VARCHAR(50)    NOT NULL
);
