#!/bin/bash

if [ "$1" == "qwertyuiop" ]; then
 
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

else
        echo "You are not authourize person, Please leave now."
        exit
fi
