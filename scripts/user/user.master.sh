#!/bin/bash

echo "[*] Adding user to $HOST_MASTER"

# Create user on master database.
docker exec $(docker ps -q -f name=$HOST_MASTER) \
		mysql -u root --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER \
		--execute="

		CREATE USER IF NOT EXISTS '$USER_MONITOR_USERNAME'@'%' identified by '$USER_MONITOR_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_MONITOR_USERNAME'@'%' WITH GRANT OPTION;\

		CREATE USER IF NOT EXISTS '$USER_SUPER_USERNAME'@'%' identified by '$USER_SUPER_PASSWORD';\
		GRANT ALL PRIVILEGES ON *.* TO '$USER_SUPER_USERNAME'@'%' WITH GRANT OPTION;\

		FLUSH PRIVILEGES;"