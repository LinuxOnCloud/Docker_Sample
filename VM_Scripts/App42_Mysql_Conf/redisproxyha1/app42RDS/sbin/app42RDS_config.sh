#!/bin/bash

case $1 in

conf_proxy)
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
	
        user_password="$2"
	passwd="$2"
	
	pkill -9 redis
	
	ip=`ip \r|grep "proto kernel  scope link"|rev|awk '{print $1}'|rev`
	
	echo "Setup Redis-Sentinel Server"
	sed -i s/"# bind 127.0.0.1 192.168.1.1"/"bind $ip"/g /etc/redis-sentinel.conf
	sed -i s/"sentinel monitor mymaster 127.0.0.1 6379 2"/"sentinel monitor mymaster 10.20.1.7 6379 2"/g /etc/redis-sentinel.conf
	sed -i s/"port 26379"/"port 26381"/g /etc/redis-sentinel.conf
	sed -i s/"# sentinel auth-pass <master-name> <password>"/"sentinel auth-pass mymaster $passwd"/g /etc/redis-sentinel.conf
	sed -i s/"sentinel down-after-milliseconds mymaster 30000"/"sentinel down-after-milliseconds mymaster 20000"/g /etc/redis-sentinel.conf
	sed -i s/"sentinel failover-timeout mymaster 180000"/"sentinel failover-timeout mymaster 30000"/g /etc/redis-sentinel.conf
	sed -i s/"# sentinel notification-script mymaster \/var\/redis\/notify.sh"/"sentinel notification-script mymaster \/app42RDS\/sbin\/redis-notify.sh"/g /etc/redis-sentinel.conf
	
	echo "Setup HAProxy Server"
	echo "# Specifies TCP timeout on connect for use by the frontend ft_redis
# Set the max time to wait for a connection attempt to a server to succeed
# The server and client side expected to acknowledge or send data.
defaults REDIS
mode tcp
timeout connect 3s
timeout server 6s
timeout client 6s

# Specifies listening socket for accepting client connections using the default
# REDIS TCP timeout and backend bk_redis TCP health check.
frontend ft_redis
bind *:6379 name redis
default_backend bk_redis

# Specifies the backend Redis proxy server TCP health settings
# Ensure it only forward incoming connections to reach a master.
backend bk_redis
option tcp-check
#tcp-check connect
tcp-check send AUTH\\ $user_password\\r\\n
tcp-check expect string +OK
tcp-check send PING\\r\\n
tcp-check expect string +PONG
tcp-check send info\\ replication\\r\\n
tcp-check expect string role:master
tcp-check send QUIT\\r\\n
tcp-check expect string +OK
server redis1 10.20.1.7:6379 check inter 1s
server redis2 10.20.1.8:6379 check inter 1s" > /etc/haproxy/haproxy.cfg

	chkconfig redis-sentinel on
	chkconfig  haproxy on
	
	echo 1 > /etc/init.d/redis
        /app42RDS/sbin/initredissentinel

	/app42RDS/sbin/ConfigConstructer
	/etc/init.d/sshd restart
	sleep 10 
	echo "#*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab
	/etc/init.d/crond restart
	/etc/init.d/redis-sentinel start
	/etc/init.d/haproxy start
        ;;

esac
