#!/bin/bash

mkdir -p $BASE_DIR/nodes/slave1/data
chmod -R 777 $BASE_DIR/nodes/slave1/data

source $BASE_DIR/nodes/slave1/init.sql.sh

docker stack deploy --compose-file $BASE_DIR/nodes/slave1/docker-compose.yaml --detach=false mariadb

source $BASE_DIR/nodes/slave1/healthcheck.sh

docker exec -i $(docker ps -q -f name=$HOST_SLAVE1) mariadb -uroot -p$SLAVE1_ROOT_PASSWORD < $BASE_DIR/nodes/slave1/initdb/01-init.sql