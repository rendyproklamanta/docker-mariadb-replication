#!/bin/bash

echo
echo ===[ Starting to resync master ]===
echo

source ./master.sh

#======================================

echo
echo ===[ Starting to resync slave1 ]===
echo

source ./slave1.sh

#======================================