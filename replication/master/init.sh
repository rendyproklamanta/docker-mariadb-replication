#!/bin/bash

# load env file into the script's environment.
source ../../env/global.sh
source ../../env/master.sh

# Deploy master
mkdir -p data
chmod -R 777 data

cd init
chmod +x init-sql.sh && ./init-sql.sh
cd ../

docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb

echo "[*] Waiting 30s for master container to be up and running..."
sleep 30