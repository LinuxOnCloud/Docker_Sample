#!/bin/bash

EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`
ip=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
passwd=`cat /etc/redis.conf |grep "requirepass"|awk '{print $2}'|tail -1|cut -d'"' -f2`

sentinel=`ps ax |grep redis-sentinel|grep -v grep|awk '{print $1}'`
if [ -z $sentinel ]; then
/etc/init.d/redis-sentinel restart
if [ $? -eq 0 ]; then
        mail -s "$setup_name : Redis-Sentinel Service Running Successfully : $ip" $Email < /var/lib/redis/logs/sentinel.log
else
        mail -s "$setup_name : Redis-Sentinel Service Starting Failed : $ip" $Email < /var/lib/redis/logs/sentinel.log
fi
else
/bin/echo "Process Redis-Sentinel Is Running"
fi

redis_server=`ps ax |grep redis|grep -v grep |grep 6379|grep -v sentinel|awk '{print $1}'`
if [ -z $redis_server ]; then
/etc/init.d/redis restart $passwd
if [ $? -eq 0 ]; then
        mail -s "$setup_name : HAProxy Service Running Successfully : $ip" $Email < /var/lib/redis/logs/redis.log
else
        mail -s "$setup_name : HAProxy Service Starting Failed : $ip" $Email < /var/lib/redis/logs/redis.log
fi
else
/bin/echo "Process Redis Server  Is Running"
fi

