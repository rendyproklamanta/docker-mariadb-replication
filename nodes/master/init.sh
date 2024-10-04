#!/bin/bash

mkdir -p $BASE_DIR/nodes/master/data
chmod -R 777 $BASE_DIR/nodes/master/data

source $BASE_DIR/nodes/master/init.sql.sh

docker stack deploy --compose-file $BASE_DIR/nodes/master/docker-compose.yaml --detach=false mariadb

source $BASE_DIR/nodes/master/healthcheck.sh