#!/bin/bash

# load env file into the script's environment.
source ../../env/global.sh
source ../../env/master.sh
source ../../env/slave1.sh

# Deploy slave1
mkdir -p data
chmod -R 777 data

cd init
chmod +x init-sql.sh && ./init-sql.sh
cd ../

docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb

## Exec init.sql
echo "[*] Waiting 30s for slave container to be up and running..."
sleep 30
docker exec -i $(docker ps -q -f name=$HOST_SLAVE1) mariadb -uroot -p$SLAVE1_ROOT_PASSWORD < init/01-init.sql