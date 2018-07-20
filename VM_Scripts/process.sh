#!/bin/bash

ip=`ip \r |grep eth0|tail -1|rev|awk '{ print $1}'|rev`

EMAIL="abc@example.com"

#d=`ps x |/bin/grep java|/bin/grep maven |/bin/grep $1 |/usr/bin/awk '{print $1}'`
d=`ps x |/bin/grep java |/bin/grep $1 |/usr/bin/awk '{print $1}'`
/bin/echo "d=$d"
if [ -z $d ]; then
	/bin/echo "`date`: Process $1 Is Currently Stopped on Host $ip, Now Script Is Starting $1 Process In Progess"| mail -s "Component $1 is Down on Host $ip" $EMAIL
	/bin/echo "Process $1 Is Currently Stopped, Now Script Is Starting $1 Process In Progess"
	cd $2 && /bin/sh $3 > $2/$1-Console.log 2>&1
	/bin/echo "Process $1 Is Started"
else
	/bin/echo "Process $1 Is Running"
	
fi