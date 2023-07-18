#!/bin/bash
source ../../demo-vars.sh

ARCH=$(uname -p)

case $ARCH in
  arm | aarch64)
    echo
    echo "Building MySQL image for ARM architecture"
    echo
    $DOCKER build -t $MYSQL_IMAGE -f Dockerfile.arm .
    ;;
  i386 | x86_64)
    echo
    echo "Building MySQL image for Intel architecture"
    echo
    $DOCKER build -t $MYSQL_IMAGE -f Dockerfile.i386 .
    ;;
  *)
    echo
    echo "Unrecognized CPU architecture: $ARCH."
esac
