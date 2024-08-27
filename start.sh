#!/bin/bash

# Create network
docker network create --driver overlay mysql-network

# load env file into the script's environment.
source env.sh

# Stopping all services
docker stack rm mariadb

# Deploy master
cd replication/master
chmod +x master.start.sh && ./master.start.sh
cd ../../

# Deploy slave1
cd replication/slave1
chmod +x slave1.start.sh && ./slave1.start.sh
cd ../../

# Resync replication
echo '*** Resync replication ***'
cd resync
chmod +x main.sh && ./main.sh
cd ../

# Deploy MaxScale
echo '*** Deploy maxscale container ***'
cd maxscale
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
cd ../

# Deploy backup
echo '*** Deploy backup container ***'
cd backup
chmod +x backup.start.sh && ./backup.start.sh
cd ../

# Deploy PMA
echo '*** Deploy PMA container ***'
docker stack deploy --compose-file docker-compose.pma.yaml --detach=false mariadb

# Enable startup service
echo '*** Set auto startup mariadb service ***'
cp mariadb-repl.service /etc/systemd/system/mariadb-repl.service
sudo systemctl enable mariadb-repl.service

# Check status after reboot
echo '*** Check mariadb service ***'
sudo journalctl -u mariadb-repl.service