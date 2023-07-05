#!/bin/bash
source ../demo-vars.sh
if [[ "$($DOCKER ps | grep $MYSQL_SERVER)" != "" ]]; then
  $DOCKER stop $MYSQL_SERVER > /dev/null && $DOCKER rm $MYSQL_SERVER > /dev/null
fi
