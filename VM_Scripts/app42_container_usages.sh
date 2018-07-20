#!/bin/bash

containername=$1
lxc_path=/var/lib/lxc

if [ -z "$containername" ]; then
	echo '{"success":"false","code":8501,"message":"no container name specified"}'
	exit 1
fi

if [ ! -d "$lxc_path/$containername" ]; then
	echo '{"success":"false","code":8502,"message":"'$containername' does not exist"}'
	exit 1
fi

case $2 in

cpu_usages)

	cpushare=`grep "lxc.cgroup.cpu.shares" $lxc_path/$containername/config |awk '{print $3}'`

	lxc-ps -n $containername |awk '{print $2}'|grep -v 'PID'>/tmp/123-$containername
	tr '\n' ' ' </tmp/123-$containername>/tmp/pid-$containername

	PID=`cat /tmp/pid-$containername`

	for cpus in $PID
	do
		cpuadd=`ps -p $cpus -o pcpu |grep -v CPU`

		if [ -z "$cpuadd" ]; then
			cpuadd=0
		fi

		echo "$cpuadd +">>/tmp/cpu-$containername
	done

	tr '\n' ' ' </tmp/cpu-$containername>/tmp/cpudone-$containername

	cpud=`cat /tmp/cpudone-$containername|rev|cut -d '+' -f2-1000|rev`

	cpuusages=`echo "scale=2; ($cpud)"|bc`

	cpu=`echo "scale=2; ($cpuusages * 10.24 * 100 / $cpushare)"|bc`

	rm /tmp/123-$containername /tmp/pid-$containername /tmp/cpu-$containername /tmp/cpudone-$containername

	date |tee -a /var/log/vmpath/$containername

	echo '{"code":5000,"success":"true","message":"Current CPU Usages In '$containername'","cpu":"'$cpu'"}' |tee -a /var/log/vmpath/$containername
	;;

memory_usages)

	mem_usages=`cat /sys/fs/cgroup/memory/lxc/$containername/memory.usage_in_bytes`

	mem=`echo "scale=2; ($mem_usages/1024/1024)"|bc`

	date |tee -a /var/log/vmpath/$containername

	echo '{"code":5000,"success":"true","message":"Current Memory Usages In '$containername'","memory":"'$mem'"}' |tee -a /var/log/vmpath/$containername
	;;

disk_usages)

	Size=`df -Th|grep $containername |awk '{print $3}'`

	Used=`df -Th|grep $containername |awk '{print $4}'`

	Avail=`df -Th|grep $containername |awk '{print $5}'`

	Use_persentage=`df -Th|grep $containername |awk '{print $6}'`
	
	echo '{"code":5000,"success":"true","message":"Current Disk Usages In '$containername'","totalDisk":"'$Size'","usedDisk":"'$Used'","availableDisk":"'$Avail'","usedPercentage":"'$Use_persentage'"}' |tee -a /var/log/vmpath/$containername
        ;;
esac
