#!/bin/bash

WAIT_TIMEOUT=300

# Get the container ID for the SLAVE1
container_id=$(docker ps -q -f name=$HOST_SLAVE1)

# Function to check if SLAVE1 is running inside the container
check_mariadb_running() {
  docker exec $container_id mariadb -uroot --password=$SLAVE1_ROOT_PASSWORD --port=$PORT_SLAVE1 --execute="SELECT 1" > /dev/null 2>&1
}

# Check if the container is running
if [ -z "$container_id" ]; then
  echo "Error: SLAVE1 container $HOST_SLAVE1 is not running."
  exit 1
fi

# Wait for SLAVE1 to be ready
echo "Waiting for SLAVE1 to be ready..."
elapsed=0
while ! check_mariadb_running; do
  sleep 5
  elapsed=$((elapsed + 5))
  if [ $elapsed -ge $WAIT_TIMEOUT ]; then
    echo "Error: SLAVE1 did not start within the timeout period."
    exit 1
  fi
  echo "SLAVE1 not ready yet, waiting..."
done

echo "SLAVE1 is running."