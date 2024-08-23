#!/bin/bash

# Deploy backup
mkdir -p data
chmod -R 777 data

docker stack deploy --compose-file docker-compose.backup.yaml --detach=false mariadb