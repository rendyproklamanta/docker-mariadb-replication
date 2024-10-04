#!/bin/bash

# Create user1
docker stack deploy --compose-file docker-compose.user1.yaml --detach=false mariadb-user1

# # Create user2
# docker stack deploy --compose-file docker-compose.user2.yaml --detach=false mariadb-user2