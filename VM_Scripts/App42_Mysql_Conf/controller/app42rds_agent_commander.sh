#!/bin/bash

if [ ! -d /var/log/app42rds ]; then
	mkdir -p /var/log/app42rds
fi

# get container IP
ip="$1"
echo -e "\n`date`" >> /var/log/app42rds/rds.log
/bin/echo "ip=$ip" 2>&1 |tee -a /var/log/app42rds/rds.log
# send command to app agent
echo "/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$ip sudo app42RDS/sbin/agent $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}" >>/var/log/app42rds/rds.log
/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$ip sudo /app42RDS/sbin/agent $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52} 2>&1 |tee -a /var/log/app42rds/rds.log
