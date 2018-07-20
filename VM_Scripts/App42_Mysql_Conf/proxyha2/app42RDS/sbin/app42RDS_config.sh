#!/bin/bash

setup_name=$2

case $1 in

conf_mha)

	/app42RDS/sbin/ConfigConstructer
        /etc/init.d/sshd restart
	mkdir -p /var/log/masterha/master-mysql
	echo "1" > /proc/sys/net/ipv4/ip_forward
	sed -i s/'net.ipv4.ip_forward = 0'/'net.ipv4.ip_forward = 1'/g /etc/sysctl.conf
	/app42RDS/sbin/config_pm
        ;;

start_mha)
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
	masterha_check_repl --conf=/etc/mha/master.cnf
	masterha_manager --conf=/etc/mha/master.cnf > /var/log/masterha/master-mysql/master-mysql.log 2>&1 &
	/app42RDS/sbin/recovery_iptables poiuytrewq
	sleep 60
        rm -rf /etc/mha/master.cnf
        ;;

set_cron)
        echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_MHA_status" >> /etc/crontab
        /etc/init.d/crond restart
        ;;

esac
