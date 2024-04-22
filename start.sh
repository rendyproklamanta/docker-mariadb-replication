#!/bin/bash

# load env file into the script's environment.
source env/master.sh
source env/slave1.sh
source env/user.sh

# Stopping all services
docker stack rm mariadb

# Deploy master
mkdir -p data/master
docker stack deploy --compose-file docker-compose.master.yaml mariadb
cd scripts
chmod +x deploy.master.sh && ./deploy.master.sh
cd ../

# Deploy slave1
mkdir -p data/slave1
docker stack deploy --compose-file docker-compose.slave1.yaml mariadb
cd scripts
chmod +x deploy.slave1.sh && ./deploy.slave1.sh
cd ../

# Deploy MaxScale
docker stack deploy --compose-file docker-compose.maxscale.yaml mariadb

# Deploy PMA
docker stack deploy --compose-file docker-compose.pma.yaml mariadb

# Deploy backup
mkdir -p data/backup
docker stack deploy --compose-file docker-compose.backup.yaml mariadb

# Set permission
chmod -R 777 data