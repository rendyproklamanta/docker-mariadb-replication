#!/bin/bash

echo "[*] Implementing master replication"
echo "[*] Host : $HOST_MASTER"
echo "[*] Waiting 30s for containers to be up and running"
sleep 30
echo

# Create user on master database.
docker exec $(docker ps -q -f name=$HOST_MASTER) \
		mysql -u root --password=$MASTER_ROOT_PASSWORD --port=$PORT_MASTER \
		--execute="SET GLOBAL time_zone = '$TIMEZONE';\

		CREATE USER IF NOT EXISTS '$REPL_USERNAME'@'%' identified by '$REPL_PASSWORD';\
		grant replication slave on *.* to '$REPL_USERNAME'@'%';\

		FLUSH PRIVILEGES;"

echo
echo ===[ $HOST_MASTER is running on port $PORT_MASTER ]===
echo

chmod +x user/user.master.sh && ./user/user.master.sh