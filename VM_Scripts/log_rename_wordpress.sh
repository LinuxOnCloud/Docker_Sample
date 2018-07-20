#!/bin/bash

# get old hostname on hname file

old_hostname=`cat /root/hname`
echo "hostname=$old_hostname"

# get current hostname

new_hostname=`hostname`
echo "new hostname=$new_hostname"

# if oldip and newip are not equal then "replace oldip with newip in iptable"
if [ "$old_hostname" != "$new_hostname" ]; then
        mv /var/www/wordpress37_php55_apache24.php /var/www/$new_hostname.php
        ln -sf /var/www/$new_hostname.php /var/www/wordpress/$new_hostname.php
        echo "$new_hostname">/root/hname
else
	echo "Hostname Is Same, Script Is Exiting"
        exit
fi
