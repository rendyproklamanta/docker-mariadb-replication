#!/bin/bash

# Define color codes
RED='\033[0;31m'
NC='\033[0m' # No Color (reset to default)

# Define the absolute path to the script directory
BASE_DIR="/var/lib/mysql"

# load env file into the script's environment.
source $BASE_DIR/env/global.sh
source $BASE_DIR/env/master.sh
source $BASE_DIR/env/slave1.sh

# Create network
docker network create --driver overlay mysql-network

# Stopping all services
docker stack rm mariadb

# ---------------------------

# Deploy master
echo "${RED}*** Deploy container master ***${NC}"
mkdir -p $BASE_DIR/replication/master/data
chmod -R 777 $BASE_DIR/replication/master/data
chmod +x $BASE_DIR/replication/master/init/init-sql.sh && $BASE_DIR/replication/master/init/init-sql.sh
docker stack deploy --compose-file $BASE_DIR/replication/master/docker-compose.yaml --detach=false mariadb
echo "[*] Waiting 30s for master container to be up and running..."
sleep 30

# Deploy slave1
echo "${RED}*** Deploy container slave1 ***${NC}"
mkdir -p $BASE_DIR/replication/slave1/data
chmod -R 777 $BASE_DIR/replication/slave1/data
chmod +x $BASE_DIR/replication/slave1/init/init-sql.sh && $BASE_DIR/replication/slave1/init/init-sql.sh
docker stack deploy --compose-file $BASE_DIR/replication/slave1/docker-compose.yaml --detach=false mariadb
echo "[*] Waiting 30s for slave container to be up and running..."
sleep 30
docker exec -i $(docker ps -q -f name=$HOST_SLAVE1) mariadb -uroot -p$SLAVE1_ROOT_PASSWORD < init/01-init.sql

# Resync replication
echo "${RED}*** Resync replication ***${NC}"
chmod +x $BASE_DIR/resync/main.sh && $BASE_DIR/resync/main.sh

# ---------------------------

echo '*** Deploy services ***'

# Deploy MaxScale
echo "${RED}*** Deploy maxscale container ***${NC}"
docker stack deploy --compose-file $BASE_DIR/services/maxscale/docker-compose.yaml --detach=false mariadb

# Deploy backup
echo "${RED}*** Deploy backup container ***${NC}"
chmod +x $BASE_DIR/services/backup/init.sh && $BASE_DIR/services/backup/init.sh

# Deploy PMA
echo "${RED}*** Deploy PMA container ***${NC}"
docker stack deploy --compose-file $BASE_DIR/services/pma/docker-compose.yaml --detach=false mariadb

# Enable startup service
echo "${RED}*** Set auto startup mariadb service ***${NC}"
cp $BASE_DIR/mariadb-repl.service /etc/systemd/system/mariadb-repl.service
sudo systemctl enable mariadb-repl.service

# Check status after reboot
# echo '*** Check mariadb service ***'
# sudo journalctl -u mariadb-repl.service