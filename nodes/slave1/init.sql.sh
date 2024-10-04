#!/bin/bash

# Create initdb directory if it doesn't exist
mkdir -p initdb

# Get the container ID for the master
container_id=$(docker ps -q -f name=$HOST_MASTER)

# Fetch master status
result=$(docker exec $container_id \
  mariadb -uroot --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER \
  --execute="SHOW MASTER STATUS\G")
  
# Extract the log file and position
log=$(echo "$result" | grep 'File:' | awk '{print $2}')
position=$(echo "$result" | grep 'Position:' | awk '{print $2}')

# Check if log and position are correctly extracted
if [ -z "$log" ] || [ -z "$position" ]; then
  echo "Error: Could not extract log file or position from master status."
  exit 1
fi

# Generate the init.sql file
cat <<EOF > initdb/01-init.sql
-- Set the global time zone
SET GLOBAL time_zone = '$TIMEZONE';

-- Stop and reset the slave
STOP SLAVE;
RESET SLAVE;

-- Apply the privilege changes
FLUSH PRIVILEGES;

-- Configure replication with the master
CHANGE MASTER TO
    MASTER_HOST='$HOST_MASTER',
    MASTER_PORT=$PORT_MASTER,
    MASTER_USER='$REPL_USERNAME',
    MASTER_PASSWORD='$REPL_PASSWORD',
    MASTER_LOG_FILE='$log',
    MASTER_LOG_POS=$position,
    MASTER_CONNECT_RETRY=10;

-- Optionally enable GTID-based replication
CHANGE MASTER TO MASTER_USE_GTID = slave_pos;

-- Start the replication slave process
START SLAVE;

-- Display the slave status for verification
SHOW SLAVE STATUS\G;
EOF

echo "01-init.sql file generated successfully."

# Generate the init.sql file
cat <<EOF > initdb/02-init.sql
-- Create user for monitor maxscale
CREATE USER IF NOT EXISTS '$MAXSCALE_USERNAME'@'%' IDENTIFIED BY '$MAXSCALE_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$MAXSCALE_USERNAME'@'%' WITH GRANT OPTION;

-- Additional user
CREATE USER IF NOT EXISTS '$SUPER_USERNAME'@'%' IDENTIFIED BY '$SUPER_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$SUPER_USERNAME'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

echo "02-init.sql file generated successfully."