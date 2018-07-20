#!/bin/bash

EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`
d=`netstat -npl|grep mysqld|grep 3306|rev|awk '{print $1}'|rev|cut -d"/" -f1`
/bin/echo "d=$d"
if [ -z $d ]; then
/etc/init.d/mysqld restart
if [ $? -eq 0 ]; then
        mail -s "$setup_name : MySQL Service Running Successfully : MySQLHA 1" $Email < /var/lib/mysql/logs/mysqld.log
else
        mail -s "$setup_name : MySQL Service Starting Failed : MySQLHA 1" $Email < /var/lib/mysql/logs/mysqld.log
fi
else
/bin/echo "Process $1 Is Running"
fi
