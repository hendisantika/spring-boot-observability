TRUNCATE TABLE loans;
ALTER TABLE loans AUTO_INCREMENT = 1;
INSERT INTO loans (id, loanid, customername, customerid, amount, loanstatus)
VALUES (1, uuid(), 'John', 101, 5000.00, 'APPROVED'),
       (2, uuid(), 'Sai', 102, 7500.00, 'APPROVED'),
       (3, uuid(), 'Alice', 103, 3000.00, 'REJECTED');
