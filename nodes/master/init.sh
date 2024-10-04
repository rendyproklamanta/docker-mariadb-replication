#!/bin/bash

mkdir -p $BASE_DIR/nodes/master/data
chmod -R 777 $BASE_DIR/nodes/master/data
cd $BASE_DIR/nodes/master && chmod +x init-sql.sh && ./init-sql.sh
docker stack deploy --compose-file $BASE_DIR/nodes/master/docker-compose.yaml --detach=false mariadb

