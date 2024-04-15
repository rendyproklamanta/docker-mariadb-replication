#!/bin/bash

echo "[*] Implementing master replication"
echo "[*] Host : $HOST_MASTER"
echo "[*] Waiting 20s for containers to be up and running"
sleep 20
echo

# Create user on master database.
docker exec $(docker ps -q -f name=$HOST_MASTER) \
		mysql -u root --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER \
		--execute="SET GLOBAL time_zone = '$TIMEZONE';\

		CREATE USER IF NOT EXISTS '$REPL_USERNAME'@'%' identified by '$REPL_PASSWORD';\
		grant replication slave on *.* to '$REPL_USERNAME'@'%';\

		CREATE USER IF NOT EXISTS '$USER_MONITOR_USERNAME'@'%' identified by '$USER_MONITOR_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_MONITOR_USERNAME'@'%' WITH GRANT OPTION;\

		CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\

		FLUSH PRIVILEGES;"

echo
echo ===[ $HOST_MASTER is running on port $PORT_MASTER ]===
echo