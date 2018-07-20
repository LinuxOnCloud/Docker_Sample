#!/bin/bash
ip=`/bin/grep -ir "$1" /var/lib/misc/dnsmasq.leases|/usr/bin/awk '{print $3}'`
/bin/echo "ip=$ip"
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/sbin/adduser $1 --disabled-password --gecos $1
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /bin/cp -arf /root/.ssh /home/$1/.
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /bin/chown -R $1.$1 /home/$1
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/bin/apt-get update -y
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/bin/apt-get install -y wget nmap vim locate gcc perl make python telnet curl zip unzip
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/bin/passwd $1 <<EOF
$1
$1
EOF 
/bin/echo "$1 ip is = $ip"
