TRUNCATE TABLE fraud_records;
ALTER TABLE fraud_records
    AUTO_INCREMENT = 1;
INSERT INTO fraud_records (id, fraud_record_id, customer_id)
VALUES (1, uuid(), 101),
       (2, uuid(), 102),
       (3, uuid(), 103),
       (4, uuid(), 104),
       (5, uuid(), 105),
       (6, uuid(), 106),
       (7, uuid(), 107),
       (8, uuid(), 108),
       (9, uuid(), 109),
       (10, uuid(), 110);
