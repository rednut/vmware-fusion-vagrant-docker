#!/bin/bash


# extract docer guest ip
export DOCKER_IP=`vagrant ssh-config | grep HostName | awk  '{print $2}'`

echo "$DOCKER_IP" > ~/.docker-ip

echo $DOCKER_IP
