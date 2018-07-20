#!/bin/bash

case $1 in

conf_proxy)
	setenforce 0
        echo "setenforce 0" >> /etc/rc.local
        sed -i 's/'SELINUX=enforcing'/'SELINUX=disabled'/g' /etc/selinux/config
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
        echo "Set File Limits"
        echo "root            soft    nofile          1000000
root            hard    nofile          1000000
azureuser       soft    nofile          1000000
azureuser       hard    nofile          1000000
postgres        soft    nofile          1000000
postgres        hard    nofile          1000000" >> /etc/security/limits.conf
        echo "Set File Limits OnSession"
        ulimit -Hn 1000000
        ulimit -Sn 1000000
        echo "Set Gurb Entry"
        sudo sed -i s/"rd_NO_DM"/"rd_NO_DM disable_mtrr_trim"/g /boot/grub/grub.conf

	/app42RDS/sbin/ConfigConstructer
        /etc/init.d/sshd restart
	iptables -t nat -F
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 5432 --to-destination 10.20.1.7:5432
	/etc/init.d/iptables save
#	iptables-save > /etc/network/iptables.rules	
#	echo "pre-up iptables-restore < /etc/network/iptables.rules" >> /etc/network/interfaces.d/eth0.cfg
        ;;

conf_master1)
	db_name="$2"
	user_name="$3"
        user_password="$4"
	su -c 'createuser -s repmgr' postgres
        su -c 'createdb repmgr -O repmgr' postgres
	su -c 'echo "CREATE USER '$user_name' WITH PASSWORD '"'$user_password'"';"| psql' postgres
	su -c 'echo "CREATE DATABASE '$db_name';"| psql' postgres
	su -c 'echo "GRANT ALL PRIVILEGES ON DATABASE '$db_name' to '$user_name';"| psql' postgres


#	su -c 'createuser -s repmgr' postgres
#	su -c 'createdb repmgr -O repmgr' postgres
#	su -c 'createuser '$3'' postgres
#	su -c 'createdb '$2' -O '$3'' postgres
#	su -c 'echo "ALTER USER test_user WITH PASSWORD '"'$4'"';"| psql' postgres
	sudo /etc/init.d/postgresql restart
	
	su -c "repmgr -f /etc/repmgr/repmgr.conf master register" postgres
	sudo /etc/init.d/postgresql restart
	su -c "repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres

#	db_name="$2"
#	user_name="$3"
#        user_password="$4"
#        echo "RESET MASTER;"|mysql
#	echo "show master status \G;"|mysql > /tmp/master_position
#        echo "GRANT ALL PRIVILEGES ON *.* To 'root'@'localhost' IDENTIFIED BY 'App42ShepAdmin' WITH GRANT OPTION;"|mysql
#        echo "GRANT REPLICATION SLAVE ON *.* TO 'slave_user'@'%' IDENTIFIED BY 'App42RDSSlavePawword';"|mysql -u root -pApp42ShepAdmin
#        echo "GRANT CREATE,DROP,LOCK TABLES,REFERENCES,EVENT,ALTER,DELETE,INDEX,INSERT,SELECT,UPDATE,CREATE TEMPORARY TABLES,TRIGGER,CREATE VIEW,SHOW VIEW,ALTER ROUTINE,CREATE ROUTINE,EXECUTE,FILE,CREATE TABLESPACE,CREATE USER,PROCESS,SHOW DATABASES,SHUTDOWN ON *.* To '$user_name'@'%' IDENTIFIED BY '$user_password' WITH GRANT OPTION;"|mysql -u root -pApp42ShepAdmin
#	echo "create database $db_name;"|mysql -u root -pApp42ShepAdmin
#        echo "GRANT ALL PRIVILEGES ON *.* To 'mhauser'@'%' IDENTIFIED BY 'App42RDSMHAPassword' WITH GRANT OPTION;"|mysql -u root -pApp42ShepAdmin
#	echo "FLUSH PRIVILEGES;"|mysql -u root -pApp42ShepAdmin
        ;;

conf_slave1)
	sudo /etc/init.d/postgresql stop	
	sudo pkill -9 postgres
	cd /var/lib/postgresql/9.6/ &&  mv main main.old && mkdir main && chown -R postgres.postgres main && chmod 700 main
	su -c "repmgr -f /etc/repmgr/repmgr.conf --force --rsync-only -h 10.20.1.7 -d repmgr -U repmgr --verbose standby clone" postgres
	/etc/init.d/postgresql start && su -c "repmgr -f /etc/repmgr/repmgr.conf --force standby register" postgres
	su -c "repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres
#        ssh -i /root/.ssh/id_rsa root@10.20.1.8 echo "CHANGE MASTER TO MASTER_HOST = '10.20.1.7', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='mysqld-bin.000004', MASTER_LOG_POS=120;"|mysql
#	echo "FLUSH PRIVILEGES;"|mysql
#        echo "start slave;"|mysql
        ;;

esac
