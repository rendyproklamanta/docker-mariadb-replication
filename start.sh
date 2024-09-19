#!/bin/bash

# Define color codes
YELLOW='\033[0;33m'
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
echo -e "${YELLOW}**** Deploy container master ****${NC}"
mkdir -p $BASE_DIR/nodes/master/data
chmod -R 777 $BASE_DIR/nodes/master/data
cd $BASE_DIR/nodes/master && chmod +x init-sql.sh && ./init-sql.sh
docker stack deploy --compose-file $BASE_DIR/nodes/master/docker-compose.yaml --detach=false mariadb

# Deploy slave1
echo -e "${YELLOW}**** Deploy container slave1 ****${NC}"
mkdir -p $BASE_DIR/nodes/slave1/data
chmod -R 777 $BASE_DIR/nodes/slave1/data
cd $BASE_DIR/nodes/slave1 && chmod +x check-master.sh && ./check-master.sh
cd $BASE_DIR/nodes/slave1 && chmod +x init-sql.sh && ./init-sql.sh
docker stack deploy --compose-file $BASE_DIR/nodes/slave1/docker-compose.yaml --detach=false mariadb
cd $BASE_DIR/nodes/slave1 && chmod +x check-slave1.sh && ./check-slave1.sh
docker exec -i $(docker ps -q -f name=$HOST_SLAVE1) mariadb -uroot -p$SLAVE1_ROOT_PASSWORD < $BASE_DIR/nodes/slave1/initdb/01-init.sql

# Resync replication
echo -e "${YELLOW}**** Resync replication ****${NC}"
cd $BASE_DIR/resync && chmod +x main.sh && ./main.sh

# ---------------------------

echo '**** Deploy services ****'

# Deploy MaxScale
echo -e "${YELLOW}**** Deploy maxscale container ****${NC}"
docker stack deploy --compose-file $BASE_DIR/services/maxscale/docker-compose.yaml --detach=false mariadb

# Deploy backup
echo -e "${YELLOW}**** Deploy backup container ****${NC}"
cd $BASE_DIR/services/backup && chmod +x init.sh && ./init.sh

# Deploy PMA
echo -e "${YELLOW}**** Deploy PMA container ****${NC}"
docker stack deploy --compose-file $BASE_DIR/services/pma/docker-compose.yaml --detach=false mariadb

# Enable startup service
echo -e "${YELLOW}**** Set auto startup mariadb service ****${NC}"
cp $BASE_DIR/mariadb-repl.service /etc/systemd/system/mariadb-repl.service
sudo systemctl enable mariadb-repl.service

# Check status after reboot
# echo '**** Check mariadb service ****'
# sudo journalctl -u mariadb-repl.service