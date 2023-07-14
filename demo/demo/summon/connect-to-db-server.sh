#!/bin/bash
if [[ "$MYSQL_LOGIN_HOST" == "" ]]; then
  echo "Usage: summon $0"
  exit -1
fi
mysql -h $MYSQL_LOGIN_HOST -P $MYSQL_LOGIN_PORT -u $MYSQL_LOGIN_USER --password=$MYSQL_ROOT_PASSWORD
