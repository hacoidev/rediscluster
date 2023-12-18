#!/bin/bash
cwd=$(pwd)

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

for (( i=$PORT_FROM; i<=$PORT_TO; i++ ))
do
   mkdir -p ${cwd}/cluster/${i}
   chown -R redis:redis ${cwd}/cluster/
   ## Create config file redis.conf
   echo 'bind 0.0.0.0' > ${cwd}/cluster/${i}/redis.conf
   echo "port $i" >> ${cwd}/cluster/${i}/redis.conf
   echo "requirepass $REDIS_PASSWORD" >> ${cwd}/cluster/${i}/redis.conf
   echo "dir ${cwd}/cluster/${i}/" >> ${cwd}/cluster/${i}/redis.conf
   echo "cluster-enabled yes" >> ${cwd}/cluster/${i}/redis.conf
   echo "cluster-config-file ${cwd}/cluster/${i}/nodes.conf" >> ${cwd}/cluster/${i}/redis.conf
   echo "cluster-node-timeout 5000" >> ${cwd}/cluster/${i}/redis.conf
   echo "appendonly yes" >> ${cwd}/cluster/${i}/redis.conf
   echo "tcp-backlog 511" >> ${cwd}/cluster/${i}/redis.conf
   echo "maxclients 65503" >> ${cwd}/cluster/${i}/redis.conf
   echo "pidfile ${cwd}/cluster/${i}/redis.pid" >> ${cwd}/cluster/${i}/redis.conf
   echo "logfile ${cwd}/cluster/${i}/redis.log" >> ${cwd}/cluster/${i}/redis.conf


   ## Create service file
   echo '[Unit]' > /etc/systemd/system/redis_${i}.service
   echo "Description=Redis key-value database on port ${i}" >> /etc/systemd/system/redis_${i}.service
   echo "After=network.target" >> /etc/systemd/system/redis_${i}.service
   echo "[Service]" >> /etc/systemd/system/redis_${i}.service
   echo "ExecStart=/usr/bin/redis-server ${cwd}/cluster/${i}/redis.conf" >> /etc/systemd/system/redis_${i}.service
   echo "ExecStop=/bin/redis-cli -h 127.0.0.1 -p ${i} shutdown" >> /etc/systemd/system/redis_${i}.service
   echo "TimeoutStopSec=0" >> /etc/systemd/system/redis_${i}.service
   echo "User=redis" >> /etc/systemd/system/redis_${i}.service
   echo "Group=redis" >> /etc/systemd/system/redis_${i}.service
   echo "RuntimeDirectory=redis" >> /etc/systemd/system/redis_${i}.service
   echo "RuntimeDirectoryMode=2755" >> /etc/systemd/system/redis_${i}.service
   echo "LimitNOFILE=65535" >> /etc/systemd/system/redis_${i}.service
   echo "[Install]" >> /etc/systemd/system/redis_${i}.service
   echo "WantedBy=multi-user.target" >> /etc/systemd/system/redis_${i}.service

   ## Reload deamon
   systemctl daemon-reload
   systemctl enable --now redis_${i}.service
   systemctl restart redis_${i}.service

done
