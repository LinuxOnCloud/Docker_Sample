#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

if [ "$1" == "qwertyuiop" ]; then

/app42RDS/sbin/set_new_slave qwertyuiop > /tmp/set_new_slave_status &

sleep 1m

#pkill -9 perl

EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`

mutt -s "$setup_name App42RDS PostgreSQL Failover = New Master - 10.20.1.8" $Email -a /var/lib/postgresql/repmgr/repmgr.log < /var/lib/postgresql/repmgr/repmgr.log
#mail -s "$setup_name App42RDS Mysql Failover = New Master - 10.20.1.8" $Email < /var/log/masterha/master-mysql/master-mysql.log
#scp -i /root/.ssh/id_rsa /var/log/masterha/master-mysql/master-mysql.log root@10.20.1.6:/var/log/masterha/master-mysql/master-mysql.log
#rm -rf /etc/mha/master.cnf /etc/mha/recovery.cnf

else
        echo "You are not authourize person, Please leave now."
        exit
fi

