#!/bin/bash

mkdir -p $BASE_DIR/nodes/slave1/data
chmod -R 777 $BASE_DIR/nodes/slave1/data
cd $BASE_DIR/nodes/slave1 && chmod +x check-master.sh && ./check-master.sh
cd $BASE_DIR/nodes/slave1 && chmod +x init-sql.sh && ./init-sql.sh
docker stack deploy --compose-file $BASE_DIR/nodes/slave1/docker-compose.yaml --detach=false mariadb
cd $BASE_DIR/nodes/slave1 && chmod +x check-slave1.sh && ./check-slave1.sh
docker exec -i $(docker ps -q -f name=$HOST_SLAVE1) mariadb -uroot -p$SLAVE1_ROOT_PASSWORD < $BASE_DIR/nodes/slave1/initdb/01-init.sql
