#!/bin/bash

echo -e "\n`date` call App42_Cleanup script Deployment ID = $1 \n" >> /opt/iptab/cleanup.log

# set variables
lxc_path=/var/lib/lxc
vgname=lxc
new_container=$1
rootdev="$lxc_path/$new_container"

# make sure the container isn't running
/usr/bin/lxc-stop -n $new_container
/bin/sleep 1

# get container ip 
#ip=`/bin/grep -ir "ipv4" $rootdev/config|/usr/bin/awk '{print $3}'|/usr/bin/cut -d '/' -f1`

# remove container ip from iptable
#/bin/sed -i '/'$ip'/d' /opt/iptab/iptables.sh

# remove startup file
/bin/rm  /etc/lxc/auto/$new_container
# remove container mount point from fstab
/bin/sed -i "/$new_container/d" /etc/fstab
/bin/sed -i "/$new_container/d" /opt/iptab/mounttab

# reset current ip
/vmpath/sbin/iptable_reset

# container destroy via lxc-destroy command
/usr/bin/lxc-destroy -n $new_container
/bin/rm -rf $lxc_path/$new_container-1

# destroy LVM partition
/bin/umount $rootdev
/sbin/lvdisplay /dev/$vgname/$new_container > /dev/null 2>&1
if [ $? -eq 0 ]; then
	/sbin/lvremove -f $vgname/$new_container
	/bin/rm -rf $rootdev 
fi
