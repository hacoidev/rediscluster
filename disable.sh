#!/bin/bash
# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

for (( i=$PORT_FROM; i<=$PORT_TO; i++ ))
do
   systemctl disble --now redis_${i}.service
done
