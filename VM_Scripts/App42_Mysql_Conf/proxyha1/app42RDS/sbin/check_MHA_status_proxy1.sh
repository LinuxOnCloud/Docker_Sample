#!/bin/bash

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

#EMAIL="abc@example.com"
EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`
master=`iptables -t nat -L|grep 3306|rev|cut -d":" -f2|rev`

mha_pid=`ps aux|grep "masterha_manager"|grep -v grep|awk '{print $2}'`
if [ -z "$mha_pid" ]; then
	mha_pid=`ssh -i /root/.ssh/id_rsa root@10.20.1.6 "ps aux |grep masterha_manager|grep -v grep|awk '{print $2}'"`
fi
#exit 1

if [ -z "$mha_pid" ]; then

if [ 10.20.1.7 == $master ]; then
	echo "[server default]
  # mysql user and password
  user=mhauser
  password=App42RDSMHAPassword
  ssh_user=root
  # working directory on the manager
  manager_workdir=/var/log/masterha/master-mysql
  # working directory on MySQL servers
  remote_workdir=/var/log/masterha/master-mysql
  ping_interval=10
  ping_type=CONNECT

  master_ip_failover_script=/etc/mha/master_ip_failover
  #report_script=/etc/mha/send_report

  [server1]
  hostname=10.20.1.7
master_binlog_dir=/var/lib/mysql/mysql-binlog

  [server2]
  hostname=10.20.1.8
master_binlog_dir=/var/lib/mysql/mysql-binlog" > /etc/mha/master.cnf
	masterha_check_repl --conf=/etc/mha/master.cnf > /tmp/masterha_check_repl.log 2>&1
	if [ $? -eq 0 ]; then
		rm -rf /var/log/masterha/master-mysql/*
		masterha_manager --conf=/etc/mha/master.cnf > /var/log/masterha/master-mysql/master-mysql.log 2>&1 &
		if [ $? -eq 0 ]; then
			mutt -s "$setup_name : MHA Running Successfully : MySQL Master $master" $Email -a /tmp/masterha_check_repl.log < /tmp/masterha_check_repl.log
			sleep 2m
			rm -rf /etc/mha/master.cnf
		else
			mail -s "$setup_name : MHA Starting Failed : Failover is not posible : MySQL Master $master" $Email < /var/log/masterha/master-mysql/master-mysql.log
			rm -rf /etc/mha/master.cnf
		fi
	else
		mail -s "$setup_name : MHA : MySQL Replicaton Status Failed : MySQL Master $master" $Email < /tmp/masterha_check_repl.log
		rm -rf /etc/mha/master.cnf
	fi
else
	new_master=`grep "New master is" /var/log/masterha/master-mysql/master-mysql.log|cut -d"(" -f2|cut -d":" -f1`
	master="$new_master"
	echo "[server default]
  # mysql user and password
  user=mhauser
  password=App42RDSMHAPassword
  ssh_user=root
  # working directory on the manager
  manager_workdir=/var/log/masterha/master-mysql
  # working directory on MySQL servers
  remote_workdir=/var/log/masterha/master-mysql
  ping_interval=10
  ping_type=CONNECT

  master_ip_failover_script=/etc/mha/master_ip_failover_recovery
  #report_script=/etc/mha/send_report

  [server1]
  hostname=10.20.1.7
master_binlog_dir=/var/lib/mysql/mysql-binlog

  [server2]
  hostname=10.20.1.8
master_binlog_dir=/var/lib/mysql/mysql-binlog" > /etc/mha/recovery.cnf
	masterha_check_repl --conf=/etc/mha/recovery.cnf > /tmp/masterha_check_repl.log 2>&1
	if [ $? -eq 0 ]; then
		rm -rf /var/log/masterha/master-mysql/*
                masterha_manager --conf=/etc/mha/recovery.cnf > /var/log/masterha/master-mysql/master-mysql.log 2>&1 &
		if [ $? -eq 0 ]; then
			mutt -s "$setup_name : MHA Running Successfully : MySQL Master $master" $Email -a /tmp/masterha_check_repl.log < /tmp/masterha_check_repl.log
			sleep 2m
			rm -rf /etc/mha/recovery.cnf
                else
			mail -s "$setup_name : MHA Starting Failed : Failover is not posible : MySQL Master $master" $Email < /var/log/masterha/master-mysql/master-mysql.log
			rm -rf /etc/mha/recovery.cnf
                fi
        else
                mail -s "$setup_name : MHA : MySQL Replicaton Status Failed : MySQL Master $master" $Email < /tmp/masterha_check_repl.log
		rm -rf /etc/mha/recovery.cnf
        fi
fi

else

echo "MHA Is Running Fine : `date`" >> /tmp/mha_status

fi

if [ -f /etc/mha/master.cnf ] && [ -f /etc/mha/recovery.cnf ]; then
	sleep 2m
	rm -rf /etc/mha/master.cnf
	rm -rf /etc/mha/recovery.cnf
fi 
