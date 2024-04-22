#!/bin/bash

# load env file into the script's environment.
source ../env/master.sh
source ../env/slave1.sh
source ../env/user.sh

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