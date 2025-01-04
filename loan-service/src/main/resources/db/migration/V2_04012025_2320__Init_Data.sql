TRUNCATE TABLE loans;
ALTER TABLE loans AUTO_INCREMENT = 1;
INSERT INTO loans (id, loan_id, customer_name, customer_id, amount, loan_status)
VALUES (1, uuid(), 'Yuji', 101, 5000.00, 'APPROVED'),
       (2, uuid(), 'Megumi', 102, 7500.00, 'APPROVED'),
       (3, uuid(), 'Gojo', 103, 3000.00, 'REJECTED'),
       (4, uuid(), 'Naobara', 104, 3000.00, 'APPROVED'),
       (5, uuid(), 'Nanami', 105, 3000.00, 'REJECTED'),
       (6, uuid(), 'Sukuna', 106, 3000.00, 'APPROVED'),
       (7, uuid(), 'Panda', 107, 3000.00, 'REJECTED'),
       (8, uuid(), 'Geto', 108, 3000.00, 'APPROVED'),
       (9, uuid(), 'Mai', 109, 3000.00, 'REJECTED'),
       (10, uuid(), 'Maki', 110, 3000.00, 'APPROVED');
