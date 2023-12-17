#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

for vps in $VPSS
do
    echo "Installing $vps"
    for (( port=$PORT_FROM; port<=$PORT_TO; port++ ))
    do
    echo "Connect redis on $vps:$port"
    redis-cli -p $PORT_FROM -a $REDIS_PASSWORD -c cluster meet $vps $port
    done
done

redis-cli -p 7000 -a $REDIS_PASSWORD -c cluster nodes
 