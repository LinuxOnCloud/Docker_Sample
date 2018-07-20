#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

if [ "$1" == "qwertyuiop" ]; then

EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`

mutt -s "$setup_name App42RDS MongoDB Failover = New Master - $2" $Email -a /var/lib/mongo/logs/mongod.log

else
        echo "You are not authourize person, Please leave now."
        exit
fi

