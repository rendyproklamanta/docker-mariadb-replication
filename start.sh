#!/bin/bash

# Define color codes
YELLOW='\033[0;33m'
NC='\033[0m' # No Color (reset to default)

# Define the absolute path to the script directory
BASE_DIR="/var/lib/mariadb"
BACKUP_DIR="/backup/mariadb"
DATA_MASTER_DIR="/data/mariadb/master"
DATA_SLAVE1_DIR="/data/mariadb/slave1"

# load env file into the script's environment.
source $BASE_DIR/env/global.sh
source $BASE_DIR/env/master.sh
source $BASE_DIR/env/slave1.sh

# Create network
docker network create --driver overlay mariadb-network

# Stopping all services
docker stack rm mariadb

# ---------------------------

# Create docker secrets
echo -e "${YELLOW}**** Create docker secrets ****${NC}"
cd $BASE_DIR/env/secrets && chmod +x secrets.sh && ./secrets.sh

# Create addgroupmysql
sudo groupadd mysql

# Deploy master
echo -e "${YELLOW}**** Deploy container master ****${NC}"
mkdir -p $DATA_MASTER_DIR && chown -R root:mysql $DATA_MASTER_DIR  # Create directory data
cd $BASE_DIR/nodes/master && chmod +x init.sql.sh && ./init.sql.sh
docker stack deploy --compose-file $BASE_DIR/nodes/master/docker-compose.yaml --detach=false mariadb
cd $BASE_DIR/nodes/master && chmod +x healthcheck.sh && ./healthcheck.sh

# Deploy slave1
echo -e "${YELLOW}**** Deploy container slave1 ****${NC}"
mkdir -p $DATA_MASTER_DIR && chown -R root:mysql $DATA_MASTER_DIR  # Create directory data
cd $BASE_DIR/nodes/slave1 && chmod +x init.sql.sh && ./init.sql.sh
docker stack deploy --compose-file $BASE_DIR/nodes/slave1/docker-compose.yaml --detach=false mariadb
cd $BASE_DIR/nodes/slave1 && chmod +x healthcheck.sh && ./healthcheck.sh
docker exec -i $(docker ps -q -f name=$HOST_SLAVE1) mariadb -uroot -p$SLAVE1_ROOT_PASSWORD < $BASE_DIR/nodes/slave1/initdb/01-init.sql

# Resync replication
echo -e "${YELLOW}**** Resync replication ****${NC}"
source $BASE_DIR/resync/master.sh
source $BASE_DIR/resync/slave1.sh

# ---------------------------

echo '**** Deploy services ****'

# Deploy MaxScale
echo -e "${YELLOW}**** Deploy maxscale container ****${NC}"
docker stack deploy --compose-file $BASE_DIR/services/maxscale/docker-compose.yaml --detach=false mariadb

# Deploy backup
echo -e "${YELLOW}**** Deploy backup container ****${NC}"
mkdir -p $BACKUP_DIR && chmod -R 755 $BACKUP_DIR # Create directory backup
docker stack deploy --compose-file $BASE_DIR/services/backup/docker-compose.yaml --detach=false mariadb

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