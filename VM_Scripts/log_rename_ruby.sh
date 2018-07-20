#!/bin/bash

# get old hostname on hname file

old_hostname=`cat /opt/hname`
echo "hostname=$old_hostname"

# get current hostname

new_hostname=`hostname`
echo "new hostname=$new_hostname"

# if oldip and newip are not equal then "replace oldip with newip in iptable" 
if [ $old_hostname != $new_hostname ]; then
	rm /var/www/demo/$old_hostname
	ln -sf /var/www/rails_logger/public /var/www/demo/$new_hostname
	#chown $old_hostname.$old_hostname /var/www/demo/$new_hostname
	sed -i 's/'$old_hostname'/'$new_hostname'/g' /opt/nginx/conf/nginx.conf 
	echo "$new_hostname">/opt/hname
else
	echo "Hostname Is Same, Script Is Exiting"
	exit
fi
