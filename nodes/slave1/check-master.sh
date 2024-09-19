#!/bin/bash

WAIT_TIMEOUT=300

# Get the container ID for the MASTER
container_id=$(docker ps -q -f name=$HOST_MASTER)

# Function to check if MASTER is running inside the container
check_mariadb_running() {
  docker exec $container_id mariadb -uroot --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER --execute="SELECT 1" > /dev/null 2>&1
}

# Check if the container is running
if [ -z "$container_id" ]; then
  echo "Error: MASTER container $HOST_MASTER is not running."
  exit 1
fi

# Wait for MASTER to be ready
echo "Waiting for MASTER to be ready..."
elapsed=0
while ! check_mariadb_running; do
  sleep 5
  elapsed=$((elapsed + 5))
  if [ $elapsed -ge $WAIT_TIMEOUT ]; then
    echo "Error: MASTER did not start within the timeout period."
    exit 1
  fi
  echo "MASTER not ready yet, waiting..."
done

echo "MASTER is running."