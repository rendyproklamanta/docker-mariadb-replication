#!/bin/bash

# load env file into the script's environment.
source ../env.sh
source ../replication/master/scripts/master.env.sh
source ../replication/slave1/scripts/slave1.env.sh

echo
echo ===[ Starting to resync master ]===
echo

chmod +x master.sh && ./master.sh

#======================================

echo
echo ===[ Starting to resync slave1 ]===
echo

chmod +x slave1.sh && ./slave1.sh

#======================================