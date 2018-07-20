#!/bin/bash

case $1 in

create_lvm)

        disk_name=`fdisk -l|grep Disk|grep -v "Disk identifier"|sort|tail -1|awk '{print $2}'|cut -d":" -f1`
        pvcreate $disk_name
        vgcreate PostgreSQLVG $disk_name
        vgsize=`vgdisplay |grep "VG Size"|cut -d"." -f1|awk '{print $3}'`
        lvsize=`echo "$vgsize - 10"|bc`
        lvcreate -L $lvsize"G" -n PostgreSQLlv PostgreSQLVG
        lvpath=`lvdisplay |grep "LV Path"|awk '{print $3}'`
        mkfs.ext4 $lvpath
        echo "$lvpath /var/lib/postgresql ext4 defaults 1 2" >> /etc/fstab
	/etc/init.d/postgresql stop && pkill -9 postgres
        mount -a
	cd /var/lib/postgresql/ && mkdir 9.6
        cd /var/lib/postgresql/9.6 && mkdir main && chmod 700 main
	cd /var/lib/postgresql && mkdir repmgr logs
	cp -arf /root/.ssh /var/lib/postgresql/.
	cp /root/.bashrc /var/lib/postgresql/. && cp /root/.profile /var/lib/postgresql/.
	cp /home/azureuser/Installationpkg/comman-postgresql/promot.sh /var/lib/postgresql/repmgr/. && chmod +x /var/lib/postgresql/repmgr/promot.sh
	cd /var/lib &&  chown -R postgres.postgres postgresql
	echo 1 > /var/run/repmgrd.pid
	chown postgres.postgres /var/run/repmgrd.pid
	/etc/init.d/postgresql stop && pkill -9 postgres
	ln -s /usr/lib/postgresql/9.6/bin/* /usr/local/bin/
        su -c "initdb -D /var/lib/postgresql/9.6/main" postgres
	/app42RDS/sbin/ConfigConstructer
        /etc/init.d/ssh restart
	echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab
	echo "pre-up iptables-restore < /etc/network/iptables.rules" >> /etc/network/interfaces.d/eth0.cfg
        /etc/init.d/cron restart
	/etc/init.d/postgresql restart
        ;;

conf_master)
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

conf_slave)
	sudo /etc/init.d/postgresql stop	
	sudo pkill -9 postgres
	cd /var/lib/postgresql/9.6/ &&  mv main main.old && mkdir main && chown -R postgres.postgres main && chmod 700 main
	su -c "repmgr -f /etc/repmgr/repmgr.conf --force --rsync-only -h 10.20.1.7 -d repmgr -U repmgr --verbose standby clone" postgres
	/etc/init.d/postgresql start && sleep 5 && su -c "repmgr -f /etc/repmgr/repmgr.conf --force standby register" postgres
	su -c "repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres
#        ssh -i /root/.ssh/id_rsa root@10.20.1.8 echo "CHANGE MASTER TO MASTER_HOST = '10.20.1.7', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='mysqld-bin.000004', MASTER_LOG_POS=120;"|mysql
#	echo "FLUSH PRIVILEGES;"|mysql
#        echo "start slave;"|mysql
        ;;

esac
