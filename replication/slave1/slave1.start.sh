#!/bin/bash

# load env file into the script's environment.
source ../master/scripts/master.env.sh
source scripts/slave1.env.sh

# Deploy slave1
mkdir -p data
chmod -R 777 data

docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb

cd scripts
chmod +x slave1.init.sh && ./slave1.init.sh
chmod +x slave1.user.sh && ./slave1.user.sh
cd ../