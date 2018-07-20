#!/bin/bash

cpu=`ps x |/bin/grep cpu_check.sh |grep -v grep|awk '{print $1}'`
mem=`ps x |/bin/grep mem_check.sh|grep -v grep|awk '{print $1}'`

echo "cpu=$cpu"

if [ -z $cpu ]; then
	/bin/echo "Cpu Watch Script Is Currently Stopped, Now Cpu Watch Script Is Starting"
	/bin/bash /vmpath/sbin/cpu_check.sh & > /dev/null
	/bin/echo "Cpu Watch Script Is Started"
else
	/bin/echo "Cpu Watch Script Is Already Running"
fi

echo "memory=$mem"

if [ -z $mem ]; then
        /bin/echo "Memory Watch Script Is Currently Stopped, Now Memory Watch Script Is Starting"
        /bin/bash /vmpath/sbin/mem_check.sh & > /dev/null
        /bin/echo "Memory Watch Script Is Started"
else
        /bin/echo "Memory Watch Script Is Already Running"
fi
