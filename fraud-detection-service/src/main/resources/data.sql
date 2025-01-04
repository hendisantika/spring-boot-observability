TRUNCATE TABLE fraud_records;
ALTER TABLE fraud_records
    AUTO_INCREMENT = 1;
INSERT INTO fraud_records (id, fraudrecordid, customerid)
VALUES (1, uuid(), 101),
       (3, uuid(), 103);
