#!/bin/bash

# get old hostname on hname file

old_hostname=`cat /root/hname`
echo "hostname=$old_hostname"

# get current hostname

new_hostname=`hostname`
echo "new hostname=$new_hostname"

# if oldip and newip are not equal then "replace oldip with newip in iptable" 
if [ $old_hostname != $new_hostname ]; then
	mv /opt/tomcat/webapps/$old_hostname.war /opt/tomcat/webapps/$new_hostname.war
	rm -rf mv /opt/tomcat/webapps/$old_hostname
	echo "$new_hostname">/root/hname
else
	echo "Hostname Is Same, Script Is Exiting"
	exit
fi
