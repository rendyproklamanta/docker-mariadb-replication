#!/bin/bash

# load env file into the script's environment.
source env/master.sh
source env/slave1.sh
source env/user.sh

# Stopping all services
docker stack rm mariadb

# Deploy master
mkdir -p data/master
docker stack deploy --compose-file docker-compose.master.yaml --detach=false mariadb
cd scripts
chmod +x deploy.master.sh && ./deploy.master.sh
cd ../

# Deploy slave1
mkdir -p data/slave1
docker stack deploy --compose-file docker-compose.slave1.yaml --detach=false mariadb
cd scripts
chmod +x deploy.slave1.sh && ./deploy.slave1.sh
cd ../

# Deploy MaxScale
docker stack deploy --compose-file docker-compose.maxscale.yaml --detach=false mariadb

# Deploy PMA
docker stack deploy --compose-file docker-compose.pma.yaml --detach=false mariadb

# Deploy backup
mkdir -p data/backup
docker stack deploy --compose-file docker-compose.backup.yaml --detach=false mariadb

# Set permission
chmod -R 777 data

# Enable startup service
echo 'Set auto startup mariadb service...'
cp mariadb-repl.service /etc/systemd/system/mariadb-repl.service
sudo systemctl enable mariadb-repl.service

# Check status after reboot
sudo journalctl -u mariadb-repl.service