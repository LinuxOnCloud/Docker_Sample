#!/bin/bash

lvm=`/sbin/vgdisplay |grep lxc | awk '{print $3}'`
if [ "$lvm" = "lxc" ]; then
	#echo '{"code":2000,"success":"true", "message":"LVM EBS Vol. found"}'
	/bin/cat /opt/fstab >> /etc/fstab
	/bin/mount -a
	if [ $? = 0 ]; then
		#echo '{"code":2000,"success":"true", "message":"lxc base partion mount successfully"}'
		/bin/cat /opt/iptab/mounttab >> /etc/fstab
		/bin/mount -a
		if [ $? = 1 ]; then
			sleep 1
			/bin/mount -a 
		fi
		if [ $? = 0 ]; then
			#echo '{"code":2000,"success":"true", "message":"lxc container partion mount successfully"}'
			cp /opt/iptab/apache2 /etc/apache2/sites-available/default
			/etc/init.d/apache2 reload &>/dev/null
			/vmpath/sbin/setrule
			if [ $? = 0 ]; then
				#echo '{"code":2000,"success":"true", "message":"Iptables entries updated successfully"}'
				/etc/init.d/lxc restart
				/vmpath/sbin/iptable_reset
				if [ $? = 0 ]; then
					sleep 2
					lxc-list
					echo '{"code":5000,"success":"true", "message":"Volume Mounted Successfully"}'
				else
					echo '{"success":"false","code":8201, "message":"Volume Could Not Be Mounted"}'
				fi
					
			else
				echo '{"success":"false","code":8202, "message":"Iptables Entries Could Not Be Updated"}'
				exit 1
			fi
		else
			echo '{"success":"false","code":8203, "message":"Lxc Container Partition Could Not Be Mounted"}'
                	exit 1
        	fi
	else
		echo '{"success":"false","code":8204, "message":"Lxc Base Partition Could Not Be Mounted"}'
        	exit 1
	fi

else
	echo '{"success":"false","code":8205, "message":"Volume Could Not Be Found"}'
	exit 1
fi
