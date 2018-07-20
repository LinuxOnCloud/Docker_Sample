#!/bin/bash
container_name=$1
lxc_path=/var/lib/lxc
root_dev=$lxc_path/$container_name/rootfs/root

mkdir -p $root_dev/.ssh
chmod 700 $root_dev/.ssh

cp -arf /root/.ssh/id_rsa.pub $root_dev/.ssh/authorized_keys
chmod 600 $root_dev/.ssh/authorized_keys

ip=`/bin/grep -ir "$container_name" /var/lib/misc/dnsmasq.leases|/usr/bin/awk '{print $3}'`
/bin/echo "ip=$ip"
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/sbin/adduser $container_name --disabled-password --gecos $container_name
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /bin/cp -arf /root/.ssh /home/$container_name/.
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /bin/chown -R $container_name.$container_name /home/$container_name
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/bin/apt-get update -y
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/bin/apt-get install -y wget nmap vim locate gcc perl make python telnet curl zip unzip
/usr/bin/ssh -i /root/.ssh/id_rsa root@$ip /usr/bin/passwd $container_name <<EOF
$container_name
$container_name
EOF 
/bin/echo "$container_name ip is = $ip"
