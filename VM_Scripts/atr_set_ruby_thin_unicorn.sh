#!/bin/bash

# get old hostname on hname file

old_hostname=`cat /root/atrname`
echo "hostname=$old_hostname"

# get current hostname

new_hostname=`hostname`
echo "new hostname=$new_hostname"

# if oldip and newip are not equal then "replace oldip with newip in iptable" 
if [ $old_hostname != $new_hostname ]; then
	/usr/sbin/chattr -R +AacDdijsSu /opt/*
	/usr/sbin/chattr  +AacDdijsSu /home/$new_hostname/agent
	/usr/sbin/chattr  +AacDdijsSu /home/$new_hostname/.bashrc
        /usr/sbin/chattr  +AacDdijsSu /home/$new_hostname/.profile
	/usr/sbin/chattr -R -AacDdijsSu /opt/log
	/usr/sbin/chattr +u /opt/log
	
	echo "$new_hostname">/root/atrname	
else
	echo "Attributes Already Set, Script Is Exit"
	exit
fi
