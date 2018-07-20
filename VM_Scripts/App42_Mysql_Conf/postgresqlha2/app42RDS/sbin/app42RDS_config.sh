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
	
	echo "Create LVM"
	disk_name=`fdisk -l|grep Disk|grep -v "Disk identifier"|sort|tail -1|awk '{print $2}'|cut -d":" -f1`
	pvcreate $disk_name
	vgcreate PostgreSQLVG $disk_name
	vgsize=`vgdisplay |grep "VG Size"|cut -d"." -f1|awk '{print $3}'`
	lvsize=`echo "$vgsize - 10"|bc`
	lvcreate -L $lvsize"G" -n PostgreSQLlv PostgreSQLVG
	lvpath=`lvdisplay |grep "LV Path"|awk '{print $3}'`
	mkfs.ext4 $lvpath
	echo "$lvpath /var/lib/pgsql ext4 defaults 1 2" >> /etc/fstab
	mount -a
	echo "Setup PostgreSQL Dir"
	cd /var/lib/pgsql/ && mkdir 9.6
	cd /var/lib/pgsql/9.6 && mkdir data backups && chmod 700 data backups
	cd /var/lib/pgsql && mkdir repmgr
	cp -arf /root/.ssh /var/lib/pgsql/.
	cp /root/.bash_profile /var/lib/pgsql/. && cp /root/.bashrc /var/lib/pgsql/.
	cp /home/azureuser/Installationpkg/comman-postgresql/promot.sh /var/lib/pgsql/repmgr/. && chmod +x /var/lib/pgsql/repmgr/promot.sh
	cd /var/lib &&  chown -R postgres.postgres pgsql
	echo 1 > /var/run/repmgrd.pid
	sudo cp -arf /home/azureuser/Installationpkg/comman-postgresql/.ssh /var/lib/pgsql/.
	sudo chown -R postgres.postgres /var/lib/pgsql/.ssh && sudo chmod 700 /var/lib/pgsql/.ssh && sudo chmod 600 /var/lib/pgsql/.ssh/authorized_keys /var/lib/pgsql/.ssh/id_rsa && sudo chmod 644 /var/lib/pgsql/.ssh/id_rsa.pub
	chown postgres.postgres /var/run/repmgrd.pid
	sudo ln -s /usr/pgsql-9.6/bin/* /bin/
	echo "InitDB PostgreSQL"
	su -c "/usr/pgsql-9.6/bin/initdb -D /var/lib/pgsql/9.6/data/" postgres
	echo "Set PostgreSQL Config"
	total_mem=`free -m|head -2|tail -1|awk '{print $2}'`
	shared_buffers=`echo "$total_mem * 40 / 100"|bc`
	sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#wal_level = minimal"/"wal_level = hot_standby"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#archive_mode = off"/"archive_mode = on"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#archive_command = ''"/"archive_command = 'cd .'"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#max_wal_senders = 0"/"max_wal_senders = 10"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#wal_keep_segments = 0"/"wal_keep_segments = 10"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#max_replication_slots = 0"/"max_replication_slots = 1"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#hot_standby = off"/"hot_standby = on"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"#shared_preload_libraries = ''"/"shared_preload_libraries = 'repmgr_funcs'"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"max_connections = 100"/"max_connections = $2"/g /var/lib/pgsql/9.6/data/postgresql.conf
	sudo sed -i s/"shared_buffers = 128MB"/"shared_buffers = ${shared_buffers}MB"/g /var/lib/pgsql/9.6/data/postgresql.conf
	#sudo sed -i s/"#logging_collector = off"/"logging_collector = on"/g /var/lib/pgsql/9.6/data/postgresql.conf
	#sudo sed -i s/"#log_directory = 'pg_log'"/"log_directory = '\/var\/lib\/postgresql\/logs\/'"/g /var/lib/pgsql/9.6/data/postgresql.conf
	#sudo sed -i s/"#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'"/"log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'"/g /var/lib/pgsql/9.6/data/postgresql.conf
	#sudo sed -i s/"#log_file_mode = 0600"/"log_file_mode = 0600"/g /var/lib/pgsql/9.6/data/postgresql.conf

	sudo cp -arf /home/azureuser/Installationpkg/comman-postgresql/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf 
	sudo chown postgres.postgres /var/lib/pgsql/9.6/data/pg_hba.conf
	sudo chmod 600 /var/lib/pgsql/9.6/data/pg_hba.conf

	/app42RDS/sbin/ConfigConstructer
	/etc/init.d/sshd restart
	sleep 10 
	echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab
	echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_failover_agent" >> /etc/crontab
	/etc/init.d/crond restart
	/etc/init.d/postgresql-9.6 restart
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
	sudo /etc/init.d/postgresql-9.6 restart
	
	su -c "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf master register" postgres
	sudo /etc/init.d/postgresql-9.6 restart
	su -c "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres

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
	sudo /etc/init.d/postgresql-9.6 stop	
	cd /var/lib/pgsql/9.6/ &&  mv data data.old && mkdir data && chown -R postgres.postgres data && chmod 700 data
	su -c "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf --force --rsync-only -h 10.20.1.7 -d repmgr -U repmgr --verbose standby clone" postgres
	/etc/init.d/postgresql-9.6 start && sleep 5 && su -c "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf --force standby register" postgres
	su -c "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres
#        ssh -i /root/.ssh/id_rsa root@10.20.1.8 echo "CHANGE MASTER TO MASTER_HOST = '10.20.1.7', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='mysqld-bin.000004', MASTER_LOG_POS=120;"|mysql
#	echo "FLUSH PRIVILEGES;"|mysql
#        echo "start slave;"|mysql
        ;;

esac
