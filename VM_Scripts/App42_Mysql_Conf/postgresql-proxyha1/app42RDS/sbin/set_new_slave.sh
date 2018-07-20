#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

sleep 2m

#old_master=`grep "is down" /var/log/masterha/master-mysql/master-mysql.log|tail -1|awk '{print $2}'`
#old_master=`grep "Current Alive Master" /var/log/masterha/master-mysql/master-mysql.log|rev|cut -d ":" -f2|cut -d "(" -f1|rev`
#new_master=`grep "New master is" /var/log/masterha/master-mysql/master-mysql.log|cut -d"(" -f2|cut -d":" -f1`
#new_bin_log_file=`grep "All other slaves should start replication from here" /var/log/masterha/master-mysql/master-mysql.log|cut -d"'" -f4`
#new_master_log_pos=`grep "All other slaves should start replication from here" /var/log/masterha/master-mysql/master-mysql.log|cut -d"=" -f5|cut -d"," -f1`
setup_name=`hostname|cut -d"-" -f1`

#echo "`grep "is down" /var/log/masterha/master-mysql/master-mysql.log`" > /tmp/new_slave.log 2>&1
#echo "`grep "is down" /var/log/masterha/master-mysql/master-mysql.log|tail -1|awk '{print $2}'`" >> /tmp/new_slave.log 2>&1
#EMAIL="abc@example.com"
EMAIL="abc@example.com"

#echo "old_master = $old_master , new_master = $new_master , new_bin_log_file = $new_bin_log_file , new_master_log_pos = $new_master_log_pos"

counter=0

if [ "$1" == "qwertyuiop" ]; then


while [ $counter -lt 525600  ]
do


echo "nc -zv 10.20.1.8 3306" >> /tmp/new_slave.log 2>&1
#echo "old_master = $old_master , new_master = $new_master , new_bin_log_file = $new_bin_log_file , new_master_log_pos = $new_master_log_pos" >> /tmp/new_slave.log 2>&1
nc -zv 10.20.1.7 3306 >> /tmp/new_slave.log 2>&1

if [ $? -eq 0 ]; then
		sudo /etc/init.d/postgresql stop >> /tmp/new_slave.log 2>&1
        sudo pkill -9 postgres >> /tmp/new_slave.log 2>&1
        if [ $? -eq 0 ]; then
                su -c "repmgr -f /etc/repmgr/repmgr.conf --force --rsync-only -h 10.20.1.7 -d repmgr -U repmgr --verbose standby clone" postgres >> /tmp/new_slave.log 2>&1
		
                if [ $? -eq 0 ]; then
                        /etc/init.d/postgresql start >> /tmp/new_slave.log 2>&1
                                counter=525601
                        else
                                mail -s "$setup_name : New PostgreSQL Slave Starting Failure : New Slave 10.20.1.8" $Email < /tmp/new_slave.log
                        fi
                else
                        mail -s "$setup_name : New PostgreSQL Slave Cannot Connect to Master : New Slave 10.20.1.8" $Email < /tmp/new_slave.log
                fi
        else
                mail -s "$setup_name : New PostgreSQL Slave Cannot Reset Master : New Slave 10.20.1.8" $Email < /tmp/new_slave.log
        fi
else
        mail -s "$setup_name : New PostgreSQL Slave is Not Running : New Slave 10.20.1.8" $Email < /tmp/new_slave.log
fi

sleep 1m
counter=`expr $counter + 1`
echo "counter = $counter"
done
else
        echo "You are not authourize person, Please leave now."
        exit
fi

