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
redis        soft    nofile          1000000
redis        hard    nofile          1000000" >> /etc/security/limits.conf
	echo "Set File Limits OnSession"
	ulimit -Hn 1000000
	ulimit -Sn 1000000
	echo "Set Gurb Entry"
	sudo sed -i s/"rd_NO_DM"/"rd_NO_DM disable_mtrr_trim"/g /boot/grub/grub.conf
	
	pkill -9 redis
	
	echo "Create LVM"
	disk_name=`fdisk -l|grep Disk|grep -v "Disk identifier"|sort|tail -1|awk '{print $2}'|cut -d":" -f1`
	pvcreate $disk_name
	vgcreate RedisVG $disk_name
	vgsize=`vgdisplay |grep "VG Size"|cut -d"." -f1|awk '{print $3}'`
	lvsize=`echo "$vgsize - 10"|bc`
	lvcreate -L $lvsize"G" -n Redislv RedisVG
	lvpath=`lvdisplay |grep "LV Path"|awk '{print $3}'`
	mkfs.ext4 $lvpath
	echo "$lvpath /var/lib/redis ext4 defaults 1 2" >> /etc/fstab
	mount -a
	echo "Setup Redis Server"
	conn="$2"
	mem="$3"
	cd /var/lib/redis && mkdir logs data && chmod 750 data/ logs/  && chown -R redis.redis /var/lib/redis
	sed -i s/"bind 127.0.0.1"/"bind 0.0.0.0"/g /etc/redis.conf
	sed -i s/"dir \/var\/lib\/redis"/"dir \/var\/lib\/redis\/data"/g /etc/redis.conf
	sed -i s/"logfile \/var\/log\/redis\/redis.log"/"logfile \/var\/lib\/redis\/logs\/redis.log"/g /etc/redis.conf
	sed -i s/"# maxclients 10000"/"maxclients $conn"/g /etc/redis.conf
	sed -i s/"# maxmemory <bytes>"/"maxmemory ${mem}M"/g /etc/redis.conf
	
	ip=`ip \r|grep "proto kernel  scope link"|rev|awk '{print $1}'|rev`

	echo "Setup Redis-Sentinel"
	sed -i s/"logfile \/var\/log\/redis\/sentinel.log"/"logfile \/var\/lib\/redis\/logs\/sentinel.log"/g /etc/redis-sentinel.conf
	sed -i s/"# bind 127.0.0.1 192.168.1.1"/"bind $ip"/g /etc/redis-sentinel.conf
	sed -i s/"sentinel monitor mymaster 127.0.0.1 6379 2"/"sentinel monitor mymaster 10.20.1.7 6379 2"/g /etc/redis-sentinel.conf
	sed -i s/"sentinel down-after-milliseconds mymaster 30000"/"sentinel down-after-milliseconds mymaster 20000"/g /etc/redis-sentinel.conf
	sed -i s/"sentinel failover-timeout mymaster 180000"/"sentinel failover-timeout mymaster 30000"/g /etc/redis-sentinel.conf
	sed -i s/"# sentinel notification-script mymaster \/var\/redis\/notify.sh"/"sentinel notification-script mymaster \/app42RDS\/sbin\/redis-notify.sh"/g /etc/redis-sentinel.conf

	/app42RDS/sbin/initredis
	/app42RDS/sbin/initredissentinel

	chkconfig redis on
	chkconfig redis-sentinel on

	/app42RDS/sbin/ConfigConstructer
	/etc/init.d/sshd restart
	sleep 10 
	echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab
	/etc/init.d/crond restart
        ;;

conf_master)
        user_password="$2"
	passwd="$2"	
	sed -i s/"# requirepass foobared"/"requirepass $passwd"/g /etc/redis.conf
	sed -i s/"# masterauth <master-password>"/"masterauth $passwd"/g /etc/redis.conf
	sed -i s/"# sentinel auth-pass <master-name> <password>"/"sentinel auth-pass mymaster $passwd"/g /etc/redis-sentinel.conf
	/etc/init.d/redis-sentinel start
	/etc/init.d/redis start
        ;;

conf_slave)
        user_password="$2"
	passwd="$2"
        sed -i s/"# requirepass foobared"/"requirepass $passwd"/g /etc/redis.conf
	sed -i s/"# slaveof <masterip> <masterport>"/"slaveof 10.20.1.7 6379"/g /etc/redis.conf
	sed -i s/"# masterauth <master-password>"/"masterauth $passwd"/g /etc/redis.conf
        sed -i s/"# sentinel auth-pass <master-name> <password>"/"sentinel auth-pass mymaster $passwd"/g /etc/redis-sentinel.conf
	/etc/init.d/redis-sentinel start
        /etc/init.d/redis start
        ;;

esac
