#!/bin/bash
source ./demo-vars.sh
echo "Stopping and removing demo containers..."
$DOCKER stop $DEMO_CONTAINER && $DOCKER rm $DEMO_CONTAINER
$DOCKER stop $MYSQL_CONTAINER && $DOCKER rm $MYSQL_CONTAINER
$DOCKER network rm $DOCKER_NETWORK_NAME
