#!/bin/bash

echo "[*] Adding user to $HOST_SLAVE1"

# Create user on master database.
docker exec $(docker ps -q -f name=$HOST_SLAVE1) \
		mysql -u root --password=$SLAVE1_ROOT_PASSWORD --port=$PORT_SLAVE1 \
		--execute="

		CREATE USER IF NOT EXISTS '$USER_MONITOR_USERNAME'@'%' identified by '$USER_MONITOR_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_MONITOR_USERNAME'@'%' WITH GRANT OPTION;\

		CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\

		FLUSH PRIVILEGES;"