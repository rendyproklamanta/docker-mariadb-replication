#!/bin/bash

# load env file into the script's environment.
source scripts/master.env.sh

# Deploy master
mkdir -p data
chmod -R 777 data

docker stack deploy --compose-file docker-compose.yaml --detach=false mariadb

cd scripts
chmod +x master.init.sh && ./master.init.sh
chmod +x master.user.sh && ./master.user.sh
cd ../