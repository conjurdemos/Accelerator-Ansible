#!/bin/bash -x
source ../../demo-vars.sh
$DOCKER build -t $MYSQL_IMAGE .
