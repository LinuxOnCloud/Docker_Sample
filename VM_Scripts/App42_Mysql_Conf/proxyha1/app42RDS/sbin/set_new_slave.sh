#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

sleep 2m

#old_master=`grep "is down" /var/log/masterha/master-mysql/master-mysql.log|tail -1|awk '{print $2}'`
old_master=`grep "Current Alive Master" /var/log/masterha/master-mysql/master-mysql.log|rev|cut -d ":" -f2|cut -d "(" -f1|rev`
new_master=`grep "New master is" /var/log/masterha/master-mysql/master-mysql.log|cut -d"(" -f2|cut -d":" -f1`
new_bin_log_file=`grep "All other slaves should start replication from here" /var/log/masterha/master-mysql/master-mysql.log|cut -d"'" -f4`
new_master_log_pos=`grep "All other slaves should start replication from here" /var/log/masterha/master-mysql/master-mysql.log|cut -d"=" -f5|cut -d"," -f1`
setup_name=`hostname|cut -d"-" -f1`

echo "`grep "is down" /var/log/masterha/master-mysql/master-mysql.log`" > /tmp/new_slave.log 2>&1
echo "`grep "is down" /var/log/masterha/master-mysql/master-mysql.log|tail -1|awk '{print $2}'`" >> /tmp/new_slave.log 2>&1
#EMAIL="abc@example.com"
EMAIL="abc@example.com"

echo "old_master = $old_master , new_master = $new_master , new_bin_log_file = $new_bin_log_file , new_master_log_pos = $new_master_log_pos"

counter=0

if [ "$1" == "qwertyuiop" ]; then


while [ $counter -lt 525600  ]
do


echo "nc -zv $old_master 3306" >> /tmp/new_slave.log 2>&1
echo "old_master = $old_master , new_master = $new_master , new_bin_log_file = $new_bin_log_file , new_master_log_pos = $new_master_log_pos" >> /tmp/new_slave.log 2>&1
nc -zv $old_master 3306 >> /tmp/new_slave.log 2>&1
	
if [ $? -eq 0 ]; then
	echo "ssh -i /root/.ssh/id_rsa root@$old_master echo 'reset master;'|mysql -u root -pApp42ShepAdmin" >> /tmp/new_slave.log 2>&1
	ssh -i /root/.ssh/id_rsa root@"$old_master" "echo 'reset master;'|mysql -u root -pApp42ShepAdmin"  >> /tmp/new_slave.log 2>&1
	if [ $? -eq 0 ]; then
		echo "ssh -i /root/.ssh/id_rsa root@$old_master echo 'CHANGE MASTER TO MASTER_HOST = '$new_master', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='$new_bin_log_file', MASTER_LOG_POS=$new_master_log_pos;'|mysql -u root -pApp42ShepAdmin" >> /tmp/new_slave.log 2>&1
		ssh -i /root/.ssh/id_rsa root@"$old_master" "echo \"CHANGE MASTER TO MASTER_HOST = '$new_master', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='$new_bin_log_file', MASTER_LOG_POS=$new_master_log_pos;\"|mysql -u root -pApp42ShepAdmin" >> /tmp/new_slave.log 2>&1
		if [ $? -eq 0 ]; then
			echo "ssh -i /root/.ssh/id_rsa root@$old_master echo 'FLUSH PRIVILEGES;'|mysql -u root -pApp42ShepAdmin" >> /tmp/new_slave.log 2>&1
			ssh -i /root/.ssh/id_rsa root@"$old_master" "echo 'FLUSH PRIVILEGES;'|mysql -u root -pApp42ShepAdmin" >> /tmp/new_slave.log 2>&1
			echo "ssh -i /root/.ssh/id_rsa root@$old_master echo 'start slave;'|mysql -u root -pApp42ShepAdmin" >> /tmp/new_slave.log 2>&1
			ssh -i /root/.ssh/id_rsa root@"$old_master" "echo 'start slave;'|mysql -u root -pApp42ShepAdmin" >> /tmp/new_slave.log 2>&1
			if [ $? -eq 0 ]; then
				mail -s "$setup_name : New Slave is UP : New Slave $old_master" $Email < /tmp/new_slave.log
				ssh -i /root/.ssh/id_rsa root@10.20.1.6 "rm -rf /var/log/masterha/master-mysql/master-mysql.log"
				counter=525601
			else
				mail -s "$setup_name : New Slave Starting Failure : New Slave $old_master" $Email < /tmp/new_slave.log
			fi
		else
			mail -s "$setup_name : New Slave Cannot Connect to Master : New Slave $old_master" $Email < /tmp/new_slave.log
		fi
	else
		mail -s "$setup_name : New Slave Cannot Reset Master : New Slave $old_master" $Email < /tmp/new_slave.log
	fi
else
	mail -s "$setup_name : New Slave is Not Running : New Slave $old_master" $Email < /tmp/new_slave.log
fi

sleep 1m
counter=`expr $counter + 1`
echo "counter = $counter"
done
else
	echo "You are not authourize person, Please leave now."
	exit
fi
