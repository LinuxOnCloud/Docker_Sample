#!/bin/bash

# get old hostname on hname file

old_hostname=`cat /root/hname`
echo "hostname=$old_hostname"

# get current hostname

new_hostname=`hostname`
echo "new hostname=$new_hostname"

# if oldip and newip are not equal then "replace oldip with newip in iptable" 
if [ $old_hostname != $new_hostname ]; then
	sed -i 's/'$old_hostname'/'$new_hostname'/g' /etc/nginx/sites-available/default
	sed -i 's/'$old_hostname'/'$new_hostname'/g' /var/www/logger/logger.js
	chown -R $new_hostname.$new_hostname /var/www/
	echo "$new_hostname">/root/hname
else
	echo "Hostname Is Same, Script Is Exiting"
	exit
fi
