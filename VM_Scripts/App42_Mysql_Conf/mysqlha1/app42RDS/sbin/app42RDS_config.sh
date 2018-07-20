#!/bin/bash

case $1 in

create_lvm)

        setenforce 0
        echo "setenforce 0" >> /etc/rc.local
	sed -i 's/'SELINUX=enforcing'/'SELINUX=disabled'/g' /etc/selinux/config
        disk_name=`fdisk -l|grep Disk|grep -v "Disk identifier"|sort|tail -1|awk '{print $2}'|cut -d":" -f1`
        pvcreate $disk_name
        vgcreate MysqlVG $disk_name
        vgsize=`vgdisplay |grep "VG Size"|cut -d"." -f1|awk '{print $3}'`
        lvsize=`echo "$vgsize - 10"|bc`
        lvcreate -L $lvsize"G" -n Mysqllv MysqlVG
        lvpath=`lvdisplay |grep "LV Path"|awk '{print $3}'`
        mkfs.ext4 $lvpath
        echo "$lvpath /var/lib/mysql ext4 defaults 1 2" >> /etc/fstab
        mount -a
        cd /var/lib/mysql && mkdir mysql logs mysql-binlog
	touch /var/lib/mysql/logs/mysqld.log
        cd /var/lib && chown -R mysql.mysql mysql
        chkconfig mysqld on
        /etc/init.d/mysqld start
	/app42RDS/sbin/ConfigConstructer
        /etc/init.d/sshd restart
	mkdir -p /var/log/masterha/master-mysql
	echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab
        /etc/init.d/crond restart
        ;;

conf_master_mysql)
	db_name="$2"
	user_name="$3"
        user_password="$4"

	mysql_version=`mysql --version|cut -d',' -f1|rev|awk '{print $1}'|cut -d'.' -f2,3|rev`
	comp_val=`awk 'BEGIN { print (5.6 < '$mysql_version') ? "1" : "2" }'`
	if [ 1 -eq $comp_val ]; then
		sed -i s/'#validate-password=off'/'validate-password=off'/g /etc/my.cnf
	        temp_passwd=`cat /var/lib/mysql/logs/mysqld.log |grep "temporary password is generated for root"|rev|awk '{print $1}'|rev`
        	/etc/init.d/mysqld restart
	        echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'App42ShepAdmin';"|mysql -u root -p''${temp_passwd}'' --connect-expired-password
		echo "RESET MASTER;"|mysql -u root -pApp42ShepAdmin
	        echo "show master status \G;"|mysql -u root -pApp42ShepAdmin > /tmp/master_position
        	echo "GRANT ALL PRIVILEGES ON *.* To 'root'@'localhost' IDENTIFIED BY 'App42ShepAdmin' WITH GRANT OPTION;"|mysql -u root -pApp42ShepAdmin
	else
		echo "RESET MASTER;"|mysql
		echo "show master status \G;"|mysql > /tmp/master_position
		echo "GRANT ALL PRIVILEGES ON *.* To 'root'@'localhost' IDENTIFIED BY 'App42ShepAdmin' WITH GRANT OPTION;"|mysql
	fi
        echo "GRANT REPLICATION SLAVE ON *.* TO 'slave_user'@'%' IDENTIFIED BY 'App42RDSSlavePawword';"|mysql -u root -pApp42ShepAdmin
        echo "GRANT CREATE,DROP,LOCK TABLES,REFERENCES,EVENT,ALTER,DELETE,INDEX,INSERT,SELECT,UPDATE,CREATE TEMPORARY TABLES,TRIGGER,CREATE VIEW,SHOW VIEW,ALTER ROUTINE,CREATE ROUTINE,EXECUTE,FILE,CREATE TABLESPACE,CREATE USER,PROCESS,SHOW DATABASES,SHUTDOWN ON *.* To '$user_name'@'%' IDENTIFIED BY '$user_password' WITH GRANT OPTION;"|mysql -u root -pApp42ShepAdmin
	echo "create database $db_name;"|mysql -u root -pApp42ShepAdmin
        echo "GRANT ALL PRIVILEGES ON *.* To 'mhauser'@'%' IDENTIFIED BY 'App42RDSMHAPassword' WITH GRANT OPTION;"|mysql -u root -pApp42ShepAdmin
	echo "FLUSH PRIVILEGES;"|mysql -u root -pApp42ShepAdmin
        ;;

conf_slave_mysql)
	mysql_version=`mysql --version|cut -d',' -f1|rev|awk '{print $1}'|cut -d'.' -f2,3|rev`
        comp_val=`awk 'BEGIN { print (5.6 < '$mysql_version') ? "1" : "2" }'`
        if [ 1 -eq $comp_val ]; then
                sed -i s/'#validate-password=off'/'validate-password=off'/g /etc/my.cnf
                temp_passwd=`cat /var/lib/mysql/logs/mysqld.log |grep "temporary password is generated for root"|rev|awk '{print $1}'|rev`
                /etc/init.d/mysqld restart
                echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'App42ShepAdmin';"|mysql -u root -p''${temp_passwd}'' --connect-expired-password
                echo "RESET MASTER;"|mysql -u root -pApp42ShepAdmin
		echo "CHANGE MASTER TO MASTER_HOST = '10.20.1.7', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='mysqld-bin.000001', MASTER_LOG_POS=$2;"|mysql -u root -pApp42ShepAdmin
		echo "FLUSH PRIVILEGES;"|mysql -u root -pApp42ShepAdmin
	        echo "start slave;"|mysql -u root -pApp42ShepAdmin
	else
		echo "CHANGE MASTER TO MASTER_HOST = '10.20.1.7', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='mysqld-bin.000001', MASTER_LOG_POS=$2;"|mysql
        	echo "FLUSH PRIVILEGES;"|mysql
        	echo "start slave;"|mysql
	fi
        ;;

esac
