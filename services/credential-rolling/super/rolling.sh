#!/bin/bash

# Variables
DB_USER="super_usr"
DB_HOST="${DB_HOST}"
PMA_URL="${PMA_URL}"
SUPER_PASSWORD="${SUPER_PASSWORD_FILE}"
SUPER_USER="${SUPER_USER}"
PASSWORD=$(openssl rand -base64 12)  # Generate a random password

# Change the user password or create user if not exists
mysql -u$SUPER_USER -p"${SUPER_PASSWORD}" -h $DB_HOST <<EOF
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%';
ALTER USER '$DB_USER'@'%' IDENTIFIED BY '$PASSWORD';
EOF

# # set docker secrets
# echo "${PASSWORD}" | docker secret create db_super_paswd -