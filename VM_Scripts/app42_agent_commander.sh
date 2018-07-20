#!/bin/bash

if [ ! -d /var/log/vmpath ]; then
	mkdir -p /var/log/vmpath
fi

# get container IP
ip=`/bin/grep -ir "ipv4" /var/lib/lxc/$1/config|/usr/bin/awk '{print $3}'|/usr/bin/cut -d '/' -f1`
echo -e "\n`date`" >> /var/log/vmpath/$1
/bin/echo "ip=$ip" 2>&1 |tee -a /var/log/vmpath/$1
# send command to app agent
echo "/usr/bin/ssh -i /root/.ssh/id_rsa $1@$ip /home/$1/agent $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}" >>/var/log/vmpath/$1
/usr/bin/ssh -i /root/.ssh/id_rsa $1@$ip /home/$1/agent $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52} 2>&1 |tee -a /var/log/vmpath/$1
