#!/bin/bash
# Script to connect and configure a sample PostgreSQL database on the Aurora cluster

# Prerequisites:
# - psql must be installed
# - DB must be accessible from your network (EC2, VPN, or port-forwarded)
# - Pass parameters: <db-host> <db-username> <db-name>

DB_HOST=$1
DB_USER=$2
DB_NAME=$3

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_NAME" ]]; then
  echo "Usage: $0 <db-host> <db-username> <db-name>"
  exit 1
fi

echo "Connecting to DB: $DB_HOST as $DB_USER on database $DB_NAME"

psql "host=$DB_HOST user=$DB_USER dbname=$DB_NAME sslmode=require" <<EOF

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS app;

-- Create a sample table
CREATE TABLE IF NOT EXISTS app.users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255),
  created_at TIMESTAMP DEFAULT now()
);

-- Insert a sample user if not already present
INSERT INTO app.users (email, name) VALUES
  ('admin@kiusys.com', 'Kiusys Admin')
ON CONFLICT DO NOTHING;

-- Display table contents
SELECT * FROM app.users;

EOF
