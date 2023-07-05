#!/bin/bash

source ../demo-vars.sh

./stop
$DOCKER pull $MYSQL_IMAGE

$DOCKER run -d 						\
    --name $MYSQL_SERVER				\
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"	\
    -p "$MYSQL_PORT:3306"				\
    --restart unless-stopped 				\
    $MYSQL_IMAGE

echo "Waiting for server to finish starting up..."
sleep 20

echo "Initializing MySQL PetClinic database..."
cat db_create_petclinic.sql				\
  | $DOCKER exec -i $MYSQL_SERVER			\
        mysql -u root --password=$MYSQL_ROOT_PASSWORD
cat db_load_petclinic.sql				\
  | $DOCKER exec -i $MYSQL_SERVER			\
        mysql -u root --password=$MYSQL_ROOT_PASSWORD
