#!/bin/bash

# Generate the init.sql file
cat <<EOF > 01-init.sql
-- Set the global time zone
SET GLOBAL time_zone = '$TIMEZONE';

-- Create replication user if it doesn't exist
CREATE USER IF NOT EXISTS '$REPL_USERNAME'@'%' IDENTIFIED BY '$REPL_PASSWORD';

-- Grant replication slave privileges to the user
GRANT REPLICATION SLAVE ON *.* TO '$REPL_USERNAME'@'%';

-- Apply the privilege changes
FLUSH PRIVILEGES;
EOF

echo "01-init.sql file generated successfully."

# Generate the init.sql file
cat <<EOF > 02-init.sql
-- Create user for monitor maxscale
CREATE USER IF NOT EXISTS '$MAXSCALE_USERNAME'@'%' IDENTIFIED BY '$MAXSCALE_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$MAXSCALE_USERNAME'@'%' WITH GRANT OPTION;

-- Additional user
CREATE USER IF NOT EXISTS '$SUPER_USERNAME'@'%' IDENTIFIED BY '$SUPER_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$SUPER_USERNAME'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

echo "02-init.sql file generated successfully."