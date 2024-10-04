#!/bin/bash

## Create secret
echo "super_usr" | docker secret create db_super_user -
echo "SUPER_PASSWORD_SET" | docker secret create db_super_paswd -

## Show list secrets
docker secret ls