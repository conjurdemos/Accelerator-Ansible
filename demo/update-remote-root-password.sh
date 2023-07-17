#!/bin/bash

source ./demo-vars.sh

echo
echo "This script uses the CyberArk admin identity to retrieve the new database"
echo "root password from Conjur, which is presumably the intended new value for"
echo "the root password that was rotated in the vault and synced to Conjur."
echo
echo "The script uses the localhost root password which was set as an environment"
echo "variable when the server container was started. The localhost root password"
echo "is never changed to prevent getting locked out of the database."
echo
echo "Thus you can always just run this script to set the correct database password"
echo "for remote root access."
echo

LOCALHOST_ROOT_PASSWORD="$($DOCKER exec $MYSQL_SERVER env | grep MYSQL_ROOT_PASSWORD | cut -d= -f2)"
NEW_REMOTE_ROOT_PASSWORD=\'$(./ccloud-cli.sh get $MYSQL_PASSWORD_ID)\'
echo "ALTER USER 'root'@'%' IDENTIFIED BY $NEW_REMOTE_ROOT_PASSWORD; flush privileges"	\
  | $DOCKER exec -i $MYSQL_SERVER							\
	mysql -u root --password=$LOCALHOST_ROOT_PASSWORD
