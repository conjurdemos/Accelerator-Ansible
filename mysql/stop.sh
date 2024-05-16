#!/bin/bash
source ../demo-vars.sh
if [[ "$($DOCKER ps | grep $MYSQL_CONTAINER)" != "" ]]; then
  $DOCKER stop $MYSQL_CONTAINER > /dev/null && $DOCKER rm $MYSQL_CONTAINER > /dev/null
fi
