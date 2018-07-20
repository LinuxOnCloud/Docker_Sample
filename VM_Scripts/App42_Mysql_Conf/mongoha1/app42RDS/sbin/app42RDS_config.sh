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
	echo 'echo "never" > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
	echo 'echo "never" >/sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
	echo "Set File Limits"
	echo "root            soft    nofile          1000000
root            hard    nofile          1000000
azureuser       soft    nofile          1000000
azureuser       hard    nofile          1000000
mongod        soft    nofile          1000000
mongod        hard    nofile          1000000
mongod     soft    nproc     600000" >> /etc/security/limits.conf
	echo "Set File Limits OnSession"
	ulimit -Hn 1000000
	ulimit -Sn 1000000
	echo "Set Gurb Entry"
	sudo sed -i s/"rd_NO_DM"/"rd_NO_DM disable_mtrr_trim"/g /boot/grub/grub.conf
	
	echo "Create LVM"
	disk_name=`fdisk -l|grep Disk|grep -v "Disk identifier"|sort|tail -1|awk '{print $2}'|cut -d":" -f1`
	pvcreate $disk_name
	vgcreate MongoDBVG $disk_name
	vgsize=`vgdisplay |grep "VG Size"|cut -d"." -f1|awk '{print $3}'`
	lvsize=`echo "$vgsize - 10"|bc`
	lvcreate -L $lvsize"G" -n MongoDBlv MongoDBVG
	lvpath=`lvdisplay |grep "LV Path"|awk '{print $3}'`
	mkfs.ext4 $lvpath
	echo "$lvpath /var/lib/mongo ext4 defaults 1 2" >> /etc/fstab
	mount -a

	
	echo "Setup MongoDB Dir"
	cd /var/lib/mongo && mkdir data logs
	chmod -R 755 /var/lib/mongo
	/home/azureuser/Installationpkg/mongoha1/app42RDS/sbin/mykey qwertyuiop
	cp /home/azureuser/Installationpkg/mongoha1/app42RDS/sbin/mongodb-keyfile /var/lib/mongo/.
	chmod 600 /var/lib/mongo/mongodb-keyfile
	chown -R mongod.mongod /var/lib/mongo/

	sed -i s/"ulimit -u 64000"/"ulimit -u 640000"/g /etc/init.d/mongod
	
	/home/azureuser/Installationpkg/mongoha1/app42RDS/sbin/myconf qwertyuiop $2
	cp /home/azureuser/Installationpkg/mongoha1/app42RDS/sbin/mongod.conf /etc/mongod.conf
	
	/app42RDS/sbin/ConfigConstructer
	/etc/init.d/sshd restart
	sleep 10 
	echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab
	/etc/init.d/crond restart
	/etc/init.d/mongod restart
        ;;

conf_master)
        echo "rs.initiate()" | mongo
        sleep 10
        echo 'cfg = rs.conf(); cfg.members[0].host = "10.20.1.7:27017"; rs.reconfig(cfg)' | mongo
        sleep 10
        echo 'cfg = rs.conf(); cfg.members[0].priority = 2; rs.reconfig(cfg);'|mongo
        sleep 10
        echo 'rs.add("10.20.1.8:27017")'|mongo
        echo 'rs.addArb("10.20.1.5:37017")'|mongo

        sleep 30

        db_name="$2"
        user_name="$3"
        user_password="$4"

        echo 'db.getSiblingDB("'admin'").createUser( {user: "'admin'", pwd: "'App42MongoRDSDBaaS'", roles: [ "root" ] } )'|mongo
        echo "db.auth('admin', 'App42MongoRDSDBaaS');"|mongo admin -u admin -p App42MongoRDSDBaaS

        echo 'db.getSiblingDB("'$db_name'").createUser( {user: "'$user_name'", pwd: "'$user_password'", roles: [ "userAdmin", "dbAdmin", "readWrite" ] } )'|mongo admin -u admin -p App42MongoRDSDBaaS

        echo "db.auth('$user_name', '$user_password');"|mongo $db_name -u $user_name -p $user_password

        ;;


add_auth)
        sed -i s/"#security:"/"security:"/g /etc/mongod.conf
        sed -i s/"#keyFile:"/"keyFile:"/g /etc/mongod.conf
        sed -i s/"#authorization:"/"authorization:"/g /etc/mongod.conf
        /etc/init.d/mongod restart
        ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 27017 --to-destination 10.20.1.7:27017
        ssh -i /root/.ssh/id_rsa root@10.20.1.5 /etc/init.d/iptables save
        ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 27017 --to-destination 10.20.1.7:27017
        ssh -i /root/.ssh/id_rsa root@10.20.1.6 /etc/init.d/iptables save
        ;;

esac
