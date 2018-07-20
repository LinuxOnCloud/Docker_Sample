#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/pgsql-9.6/bin/
export PATH

#EMAIL="abc@example.com"
EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`
master=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep master|cut -d "=" -f2|awk '{print $1}'`
slave=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep standby|cut -d "=" -f2|awk '{print $1}'`

vm_ip=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`

if [ $vm_ip != $slave ]; then
        echo "Script Exit"
        exit 1
else
        echo "Script Continue"
fi

pid=`ps aux |grep repmgrd|grep -v grep |awk '{print $2}'`

echo "PID = $pid"
#exit 1

if [ -z "$pid" ]; then
        echo 1 > /var/run/repmgrd.pid
	chown postgres.postgres /var/run/repmgrd.pid
        if [ $? -eq 0 ]; then
                su -c '/usr/pgsql-9.6/bin/repmgrd -m -d -p /var/run/repmgrd.pid -f /etc/repmgr/repmgr.conf --verbose >> /var/lib/pgsql/repmgr/repmgr.log 2>&1' postgres
                if [ $? -eq 0 ]; then
                        mail -s "`date` : $setup_name : RepMgr Running Successfully On VM $vm_ip : PostgreSQL Master $master" $Email < /var/lib/pgsql/repmgr/repmgr.log
                else
                        mail -s "`date` : $setup_name : RepMgr Starting Failed On VM $vm_ip : Failover is not posible : PostgreSQL Master $master" $Email < /var/lib/pgsql/repmgr/repmgr.log
                fi
        else
                mail -s "`date` : $setup_name : RepMgr Starting Failed On VM $vm_ip : RepMgr PID File Not Remove : PostgreSQL Master $master" $Email < /var/lib/pgsql/repmgr/repmgr.log
        fi
else

echo "RepMgr Is Running Fine : `date`" >> /tmp/RepMgr_status

fi
