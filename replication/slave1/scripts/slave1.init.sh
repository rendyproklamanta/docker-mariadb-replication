#!/bin/bash

echo "[*] Implementing slave replication"
echo "[*] Host : $HOST_SLAVE1"
echo "[*] Waiting 30s for containers to be up and running..."
sleep 30
echo

# Get the log position and name from master
result=$(docker exec $(docker ps -q -f name=$HOST_MASTER) mysql -u root --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER --execute="show master status;")
log=$(echo $result|awk '{print $6}')
position=$(echo $result|awk '{print $5}')

echo "Result master status : $result"
echo

# Connect slave to master.
docker exec $(docker ps -q -f name=$HOST_SLAVE1) \
		mysql -u root --password=$SLAVE1_ROOT_PASSWORD --port=$PORT_SLAVE1 \
		--execute="SET GLOBAL time_zone = '$TIMEZONE';\

		STOP SLAVE;\
		RESET SLAVE;\

		FLUSH PRIVILEGES;\

		CHANGE MASTER TO\
      MASTER_HOST='$HOST_MASTER',\
      MASTER_PORT=$PORT_MASTER,\
      MASTER_USER='$REPL_USERNAME',\
      MASTER_PASSWORD='$REPL_PASSWORD',\
      MASTER_LOG_POS=$log,\
		MASTER_LOG_FILE='$position',\
		MASTER_CONNECT_RETRY=10;\

		CHANGE MASTER TO MASTER_USE_GTID = slave_pos;\

		START SLAVE;\

		SHOW SLAVE STATUS\G;"

echo
echo ===[ $HOST_SLAVE1 is running on port $PORT_SLAVE1 ]===
echo