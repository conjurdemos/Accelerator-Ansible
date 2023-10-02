#!/bin/bash

source ../demo-vars.sh

./stop.sh

if [[ "$($DOCKER images -q $MYSQL_IMAGE)" = "" ]]; then
  pushd build
    ./build.sh
  popd
fi

$DOCKER run -d 						\
    --name $MYSQL_SERVER				\
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"	\
    -p "$MYSQL_LOGIN_PORT:3306"				\
    --restart unless-stopped 				\
    $MYSQL_IMAGE

echo "Waiting for MySQL server to finish starting up..."
sleep 10
