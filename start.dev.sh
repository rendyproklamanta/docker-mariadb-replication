#!/bin/bash

# Init swarm
docker swarm init
docker network create --driver overlay mysql-network

# load env file into the script's environment.
source env.sh

# Stopping all services
docker stack rm mariadb

# Deploy master
cd replication/master && chmod +x master.start.sh && ./master.start.sh
cd ../../

# Deploy slave1
cd replication/slave1
chmod +x slave1.start.sh && ./slave1.start.sh
cd ../../

# Deploy MaxScale
cd maxscale
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
cd ../

# # Deploy backup
# cd backup
# docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
# cd ../

# Deploy PMA
docker stack deploy --compose-file docker-compose.pma.yaml --detach=false mariadb
