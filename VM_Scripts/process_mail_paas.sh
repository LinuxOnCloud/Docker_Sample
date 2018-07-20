#!/bin/bash


d=`ps x |/bin/grep process_check_PaaS.sh|/bin/grep $1 |/usr/bin/awk '{print $1}'`

echo "pid=$d"

if [ -z $d ]; then
	
	/bin/echo "Mail Process $1 Is Currently Stopped, Now Script Is Starting $1 Process In Progess"
	/bin/bash /vmpath/sbin/process_check_PaaS.sh $1 & > /dev/null
	/bin/echo "Process $1 Is Started"
else
	/bin/echo "Process $1 Is Running"
	
fi
