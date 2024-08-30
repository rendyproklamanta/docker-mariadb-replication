#!/bin/bash

# Stopping all services
docker stack rm mariadb

# Init swarm
docker swarm init
docker network create --driver overlay mysql-network

## Deploy replication
cd replication

# Deploy master
cd master
chmod +x init.sh && ./init.sh
cd ../

# Deploy slave1
cd slave1
chmod +x init.sh && ./init.sh
cd ../

cd ../

# Resync replication
echo '*** Resync replication ***'
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
