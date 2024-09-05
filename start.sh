#!/bin/bash

# Create network
docker network create --driver overlay mysql-network

# Stopping all services
docker stack rm mariadb

# ---------------------------

## Deploy replication
cd replication

# Deploy master
echo '*** Deploy container master ***'
cd master
chmod +x init.sh && ./init.sh
cd ../

# Deploy slave1
echo '*** Deploy container slave1 ***'
cd slave1
chmod +x init.sh && ./init.sh
cd ../

cd ../

# Resync replication
echo '*** Resync replication ***'
cd resync
chmod +x main.sh && ./main.sh
cd ../

# ---------------------------

echo '*** Deploy services ***'
cd services

# Deploy MaxScale
echo '*** Deploy maxscale container ***'
cd maxscale
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
cd ../

# Deploy backup
echo '*** Deploy backup container ***'
cd backup
chmod +x init.sh && ./init.sh
cd ../

# Deploy PMA
echo '*** Deploy PMA container ***'
cd pma
docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb
cd ../

# Enable startup service
cd ../
echo '*** Set auto startup mariadb service ***'
cp mariadb-repl.service /etc/systemd/system/mariadb-repl.service
sudo systemctl enable mariadb-repl.service

# Check status after reboot
# echo '*** Check mariadb service ***'
# sudo journalctl -u mariadb-repl.service