#!/bin/bash

EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`
#d=`netstat -npl|grep mysqld|grep 3306|rev|awk '{print $1}'|rev|cut -d"/" -f1`
day=`date|awk '{print $1}'`
d=`netstat -tunpl|grep postmaster|grep 5432|grep -v tcp6|rev|awk '{print $1}'|rev|cut -d"/" -f1|head -1`
/bin/echo "d=$d"

if [ -z $d ]; then
/etc/init.d/postgresql-9.6 restart
if [ $? -eq 0 ]; then
        mail -s "$setup_name : PostgreSQL Service Running Successfully : PostgreSQLHA1" $Email < /var/lib/pgsql/9.6/data/pg_log/postgresql-$day.log
else
        mail -s "$setup_name : PostgreSQL Service Starting Failed : PostgreSQLHA1" $Email < /var/lib/pgsql/9.6/data/pg_log/postgresql-$day.log
fi
else
/bin/echo "Process $1 Is Running"
fi

