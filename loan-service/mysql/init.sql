CREATE SCHEMA loan_service;
CREATE SCHEMA fraud_detection;
GRANT
ALL
PRIVILEGES
ON
loan_service
.
*
TO
'yu71'@'%';
GRANT ALL PRIVILEGES ON fraud_detection.* TO
'yu71'@'%';
FLUSH
PRIVILEGES;
