#!/bin/bash

vg=`vgdisplay |grep "VG Name"|awk '{print $3}'`

if [ $vg = vmpath ]; then
	cp /home/ubuntu/.ssh/authorized_keys /tmp/
	counter=0
	while [ $counter -le 4 ]
	do
		mount /dev/vmpath/home /home/
		state=$?
		echo "state = $state"
		
		if [ $state -eq 0 ]; then
			counter=4
		fi
		
		counter=$((counter+1))
		echo "counter=$counter"
		sleep 1
	done
	
	if [ $state -eq 0 ]; then
		echo "/dev/vmpath/home   /home        ext4   defaults        0 0" >> /etc/fstab
		
		if [ $? -eq 0 ]; then
			cp /tmp/authorized_keys /home/ubuntu/.ssh/authorized_keys
        	        chmod 600 /home/ubuntu/.ssh/authorized_keys
	                chown ubuntu.ubuntu /home/ubuntu/.ssh/authorized_keys
			echo '{"code":5000,"success":"true", "message":"Volume Mounted Successfully"}'
		else
			echo '{"success":"false","code":8301, "message":"Volume Mounted, But Auto Startup Mounting Entry Failed"}'
		fi
	else
		echo '{"success":"false","code":8302, "message":"Volume Could Not Be Mounted"}'
	fi
		 
else
	echo '{"success":"false","code":8303, "message":"Volume Could Not Be Found"}'
fi

