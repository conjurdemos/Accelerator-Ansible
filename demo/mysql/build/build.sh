#!/bin/bash
source ../../demo-vars.sh

if [[ $(uname -p) == arm ]]; then
  echo
  echo "Building MySQL image for ARM architecture"
  echo
  $DOCKER build -t $MYSQL_IMAGE -f Dockerfile.arm .
else
  echo
  echo "Building MySQL image for Intel architecture"
  echo
  $DOCKER build -t $MYSQL_IMAGE -f Dockerfile.i386 .
fi
