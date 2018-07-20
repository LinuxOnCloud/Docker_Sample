#!/bin/bash

EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`
#d=`netstat -npl|grep mysqld|grep 3306|rev|awk '{print $1}'|rev|cut -d"/" -f1`
d=`netstat -tunpl|grep postgres|grep 5432|grep -v tcp6|rev|awk '{print $1}'|rev|cut -d"/" -f1`
/bin/echo "d=$d"
if [ -z $d ]; then
/etc/init.d/postgresql restart
if [ $? -eq 0 ]; then
        mail -s "$setup_name : PostgreSQL Service Running Successfully : PostgreSQLHA2" $Email < /var/log/postgresql/postgresql-9.6-main.log
else
        mail -s "$setup_name : PostgreSQL Service Starting Failed : PostgreSQLHA2" $Email < /var/log/postgresql/postgresql-9.6-main.log
fi
else
/bin/echo "Process $1 Is Running"
fi
