#!/bin/bash
set -e

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS loan_service;
  CREATE DATABASE IF NOT EXISTS fraud_detection;
  GRANT ALL PRIVILEGES ON loan_service.* TO '$MYSQL_USER'@'%';
  GRANT ALL PRIVILEGES ON fraud_detection.* TO '$MYSQL_USER'@'%';
EOSQL
