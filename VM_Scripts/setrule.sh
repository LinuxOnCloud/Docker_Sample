#!/bin/bash
# get old ip on OldIP file
oldip=`/bin/grep PREROUTING /opt/iptab/iptables.sh |/usr/bin/tail -1 |/usr/bin/awk '{print $9}'`
echo "oldip=$oldip"
# get current IP
newip=`/sbin/ip \r|/bin/grep eth0|/bin/grep src|/usr/bin/awk '{print $9}'`
echo "newip=$newip"

# if oldip and newip are not equal then "replace oldip with newip in iptable" 
if [ "$oldip" != "info" ]; then

if [ "$oldip" != "$newip" ]; then
	/bin/sed -i 's/'$oldip'/'$newip'/g' /opt/iptab/iptables.sh
	/sbin/iptables -t nat -F
	/bin/bash /opt/iptab/iptables.sh
	/sbin/iptables-save >/etc/iptables.rule
else
	/bin/echo "IP is Same, Script is Exiting"
	exit
fi
#else
#	exit
fi
