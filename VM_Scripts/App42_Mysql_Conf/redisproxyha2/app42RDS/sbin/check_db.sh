#!/bin/bash

EMAIL="abc@example.com"
setup_name=`hostname|cut -d"-" -f1`
ip=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`

sentinel=`ps ax |grep redis-sentinel|grep -v grep|awk '{print $1}'`
if [ -z $sentinel ]; then
/etc/init.d/redis-sentinel restart
if [ $? -eq 0 ]; then
        mail -s "$setup_name : Redis-Sentinel Service Running Successfully : $ip" $Email < /var/log/redis/sentinel.log
else
        mail -s "$setup_name : Redis-Sentinel Service Starting Failed : $ip" $Email < /var/log/redis/sentinel.log
fi
else
/bin/echo "Process Redis-Sentinel Is Running"
fi

haproxy=`ps ax |grep proxy|grep -v grep|awk '{print $1}'`
if [ -z $haproxy ]; then
/etc/init.d/haproxy restart > /tmp/haproxy 2>&1
if [ $? -eq 0 ]; then
        mail -s "$setup_name : HAProxy Service Running Successfully : $ip" $Email < /tmp/haproxy
else
        mail -s "$setup_name : HAProxy Service Starting Failed : $ip" $Email < /tmp/haproxy
fi
else
/bin/echo "Process HAProxy Is Running"
fi

