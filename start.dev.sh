#!/bin/bash

# Define color codes
RED='\033[0;31m'
NC='\033[0m' # No Color (reset to default)

# load env file into the script's environment.
source ./env/global.sh
source ./env/master.sh
source ./env/slave1.sh

# Init swarm
docker swarm init
docker network create --driver overlay mysql-network

# Stopping all services
docker stack rm mariadb

# Deploy master
echo "${RED}*** Deploy container master ***${NC}"
cd ./replication/master
mkdir -p data
chmod -R 777 data
chmod +x init/init-sql.sh && init/init-sql.sh
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
echo "[*] Waiting 30s for master container to be up and running..."
sleep 30

cd ../../

# Deploy slave1
echo "${RED}*** Deploy container slave1 ***${NC}"
cd ./replication/slave1
mkdir -p data
chmod -R 777 data
chmod +x init/init-sql.sh && init/init-sql.sh
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
echo "[*] Waiting 30s for slave container to be up and running..."
sleep 30
docker exec -i $(docker ps -q -f name=$HOST_SLAVE1) mariadb -uroot -p$SLAVE1_ROOT_PASSWORD < init/01-init.sql

cd ../../

# Resync replication
echo "${RED}*** Resync replication ***${NC}"
cd resync
chmod +x main.sh && ./main.sh

cd ../

# --------------------------

echo '*** Deploy services ***'
cd services

# Deploy MaxScale
cd maxscale
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
cd ../

# Deploy backup
cd backup
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
cd ../

# Deploy PMA
cd pma
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
cd ../
