#!/bin/bash
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

init_command="redis-cli -p $PORT_FROM -a $REDIS_PASSWORD --cluster create "
for i in {$PORT_FROM..$PORT_TO}
do
init_command=$init_command"127.0.0.1:$i "
done
init_command+="--cluster-replicas 0"
eval $init_command