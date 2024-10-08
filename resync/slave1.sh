#!/bin/bash

echo
echo ===[ Starting to resync slave1 ]===
echo

# Get the log position and name from master
result=$(docker exec $(docker ps -q -f name=$HOST_MASTER) mariadb -u root --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER --execute="show master status;")
log=$(echo $result|awk '{print $6}')
position=$(echo $result|awk '{print $5}')

docker exec $(docker ps -q -f name=$HOST_SLAVE1) \
		mariadb -u root --password=$SLAVE1_ROOT_PASSWORD --port=$PORT_SLAVE1 \
		--execute="

		STOP SLAVE;\
		RESET SLAVE;\

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
echo ===[ $HOST_SLAVE1 resync complete ]===
echo