#!/bin/bash

# load env file into the script's environment.
source env/master.sh
source env/slave1.sh
source env/user.sh

echo
echo Starting deploying slave1...
echo

cd ../
docker compose -f docker-compose.slave1.yaml up -d --force-recreate --build

echo "[*] Implementing slave replication"
echo "[*] Host : $HOST_SLAVE1"
echo "[*] Waiting 20s for containers to be up and running..."
sleep 20
echo

# Get the log position and name from master
result=$(docker exec $(docker ps -q -f name=$HOST_MASTER) mysql -u root --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER --execute="show master status;")
log=$(echo $result|awk '{print $6}')
position=$(echo $result|awk '{print $5}')

echo "Result master : $result"
echo

# Connect slave to master.
docker exec $(docker ps -q -f name=$HOST_SLAVE1) \
		mysql -u root --password=$SLAVE1_ROOT_PASSWORD --port=$PORT_SLAVE1 \
		--execute="SET GLOBAL time_zone = '$TIMEZONE';\

		STOP SLAVE;\
		RESET SLAVE;\

		CREATE USER IF NOT EXISTS '$USER_MONITOR_USERNAME'@'%' identified by '$USER_MONITOR_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_MONITOR_USERNAME'@'%' WITH GRANT OPTION;\

		CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_SUPER_USERNAME'@'%';\

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