#!/bin/bash

# load env file into the script's environment.
source env/master.sh
source env/slave1.sh
source env/user.sh

# Stopping all services
docker compose -f docker-compose.master.yaml down
docker compose -f docker-compose.slave1.yaml down
docker compose -f docker-compose.maxscale.yaml down
docker compose -f docker-compose.backup.yaml down
docker compose -f docker-compose.pma.yaml down

# Deploy master
mkdir -p data/master
docker compose -f docker-compose.master.yaml up -d --force-recreate
cd scripts
chmod +x deploy.master.sh && ./deploy.master.sh
cd ../

# Deploy slave1
mkdir -p data/slave1
docker compose -f docker-compose.slave1.yaml up -d --force-recreate
cd scripts
chmod +x deploy.slave1.sh && ./deploy.slave1.sh
cd ../

# Deploy MaxScale
docker compose -f docker-compose.maxscale.yaml up -d --force-recreate

# Deploy PMA
docker compose -f docker-compose.pma.yaml up -d --force-recreate

# Deploy backup
mkdir -p data/backup
docker compose -f docker-compose.backup.yaml up -d --force-recreate

# Set permission
chmod -R 777 data