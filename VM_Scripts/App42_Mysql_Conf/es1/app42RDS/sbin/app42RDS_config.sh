#!/bin/bash

case $1 in

create_lvm)
	echo "disable SELINUX"
	setenforce 0
        echo "setenforce 0" >> /etc/rc.local
        sed -i 's/'SELINUX=enforcing'/'SELINUX=disabled'/g' /etc/selinux/config
	echo "Set IP Forwording"
	echo "1" > /proc/sys/net/ipv4/ip_forward
        sed -i s/'net.ipv4.ip_forward = 0'/'net.ipv4.ip_forward = 1'/g /etc/sysctl.conf
	echo "Set Kernel Limits"
	echo "999999" > /proc/sys/fs/file-max
	echo "8388608" > /proc/sys/net/core/rmem_max
	echo "8388608" > /proc/sys/net/core/wmem_max
	echo "65536" > /proc/sys/net/core/wmem_default
	echo "65536" > /proc/sys/net/core/rmem_default
	echo "8388608 8388608 8388608" > /proc/sys/net/ipv4/tcp_mem
	echo "4096 65536 8388608" > /proc/sys/net/ipv4/tcp_wmem
	echo "4096 87380 8388608" > /proc/sys/net/ipv4/tcp_rmem
	echo "128 3200 256 256" > /proc/sys/kernel/sem
	echo "65535" > /proc/sys/net/core/somaxconn
	echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
	echo "fs.file-max = 999999" >> /etc/sysctl.conf
	echo "net.core.rmem_max = 8388608" >> /etc/sysctl.conf
	echo "net.core.wmem_max = 8388608" >> /etc/sysctl.conf
	echo "net.core.rmem_default = 65536" >> /etc/sysctl.conf
	echo "net.core.wmem_default = 65536" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_rmem = 4096 87380 8388608" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_wmem = 4096 65536 8388608" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_mem = 8388608 8388608 8388608" >> /etc/sysctl.conf
	echo "net.ipv4.route.flush = 1" >> /etc/sysctl.conf
	echo "kernel.sem=128 3200 256 256" >> /etc/sysctl.conf
	echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf
	echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
	sysctl vm.overcommit_memory=1
	echo 'echo "never" > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
	echo "Set File Limits"
	echo "root            soft    nofile          1000000
root            hard    nofile          1000000
azureuser       soft    nofile          1000000
azureuser       hard    nofile          1000000
elasticsearch        soft    nofile          1000000
elasticsearch        hard    nofile          1000000
elasticsearch   soft    nproc     600000" >> /etc/security/limits.conf
	echo "Set File Limits OnSession"
	ulimit -Hn 1000000
	ulimit -Sn 1000000
	ulimit -u 600000
	echo "Set Gurb Entry"
	sudo sed -i s/"rd_NO_DM"/"rd_NO_DM disable_mtrr_trim"/g /boot/grub/grub.conf
	
	
	echo "Create LVM"
	disk_name=`fdisk -l|grep Disk|grep -v "Disk identifier"|sort|tail -1|awk '{print $2}'|cut -d":" -f1`
	pvcreate $disk_name
	vgcreate ESVG $disk_name
	vgsize=`vgdisplay |grep "VG Size"|cut -d"." -f1|awk '{print $3}'`
	lvsize=`echo "$vgsize - 10"|bc`
	lvcreate -L $lvsize"G" -n ESlv ESVG
	lvpath=`lvdisplay |grep "LV Path"|awk '{print $3}'`
	mkfs.ext4 $lvpath
	echo "$lvpath /var/lib/elasticsearch/ ext4 defaults 1 2" >> /etc/fstab
	mount -a
	echo "Setup Redis Server"
	conn="$2"
	cd /var/lib/elasticsearch && mkdir logs data && chmod 750 data/ logs/  && chown -R elasticsearch.elasticsearch /var/lib/elasticsearch
	/app42RDS/sbin/myconf qwertyuiop $conn
	cp /app42RDS/sbin/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml && chown root.elasticsearch /etc/elasticsearch/elasticsearch.yml
	
	cd /opt && wget https://s3-ap-southeast-1.amazonaws.com/app42packege/x-pack-5.6.4.zip
	/usr/share/elasticsearch/bin/elasticsearch-plugin install file:///opt/x-pack-5.6.4.zip << EOF
y
y
EOF
	
	chkconfig elasticsearch on

	/app42RDS/sbin/ConfigConstructer
	/etc/init.d/sshd restart
	sleep 10 
	echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab
	/etc/init.d/crond restart
	/etc/init.d/elasticsearch start
        ;;

conf_master)
	user_name="$2"
        user_password="$3"
	curl -XPUT -u elastic:changeme 'localhost:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d '{ "password" : "App42ElasticRDS" }'
	curl -XPOST -u elastic:App42ElasticRDS 'localhost:9200/_xpack/security/user/'$user_name'?pretty' -H 'Content-Type: application/json' -d '{ "password" : "'$user_password'", "roles" : [ "superuser" ], "full_name" : "Admin", "email" : "admin@example.com", "metadata" : { "intelligence" : 7 } }'
	
        ;;

esac
