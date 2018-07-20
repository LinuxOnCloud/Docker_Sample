#!/bin/bash


case $1 in

get.system.info)
	used_cpu=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
	echo 1 > /proc/sys/vm/drop_caches
	total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`
        used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
        mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
	load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
        echo '{"code":5000,"success":"true","message":"Current System Info", "CPU":"'$used_cpu'", "Memory":"'$mem_percent'", "Load Avg":"'$load'"}'
		;;

get.postgresvm.info)
                d=`netstat -npl|grep postmaster|grep 5432|head -1|rev|awk '{print $1}'|rev|cut -d"/" -f1`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        used_cpu=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
                        echo 1 > /proc/sys/vm/drop_caches
                        total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`
                        used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
                        mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
			dsk=`df  -T|grep "/var/lib/pgsql"|awk '{print $3}'`
			disk_MB=`echo "$dsk / 1000 + 50"|bc`
			load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
                       #conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                       # conn=`echo $conn_stat|grep "Threads_connected"|awk '{print $8}'`
			conn=`su -c 'echo "SELECT count(*) FROM pg_stat_activity;"|psql' postgres | tail -3 | head -1`
                       #cache=`echo $conn_stat|grep "Threads_cached"|awk '{print $6}'`
                       #max_conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW VARIABLES LIKE "max_connections"' 2> /tmp/err1`
                       #max_conn=`echo $max_conn_stat|grep "max_connections"|awk '{print $4}'`
                        max_conn=`cat /var/lib/pgsql/9.6/data/postgresql.conf | grep "max_connections"|awk '{print $3}'`
                        if [ -z "$conn_stat" ]; then
                                err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 1040 -eq $err ]; then
                                        conn="-1"
                                        cache="-1"
                                fi
                        fi
			if [ -z "$max_conn_stat" ]; then
				err=`cat /tmp/err1 |grep "ERROR"|awk '{print $2}'`
                                if [ 1040 -eq $err ]; then
                                        max_conn="-1"
                                fi
                        fi
			rm -rf /tmp/err /tmp/err1
                        echo '{"code":5000,"success":"true","message":"Current PostgreSql VM Info", "CPU":"'$used_cpu'", "Memory":"'$mem_percent'", "Load Avg":"'$load'", "Threads Connected":"'$conn'", "Max Connection":"'$max_conn'", "Used Data Disk":"'$disk_MB'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current PostgreSql VM Info Could Not Be Fetch, Due To PostgreSql Not Running"}'
                fi
        ;;
		
get.system.cpu)
        used_cpu=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
        echo '{"code":5000,"success":"true","message":"Current System CPU Usages","CPU":"'$used_cpu'"}'
        ;;

get.system.memory)
	echo 1 > /proc/sys/vm/drop_caches
        total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`
        used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
        mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
        echo '{"code":5000,"success":"true","message":"Current System Memory Usages","Memory":"'$mem_percent'"}'
        ;;

get.postgres.connection)
		d=`netstat -npl|grep postmaster|grep 5432|head -1|rev|awk '{print $1}'|rev|cut -d"/" -f1`
		/bin/echo "d=$d"
		if [ ! -z $d ]; then
		#	conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                #       conn=`echo $conn_stat|grep "Threads_connected"|awk '{print $8}'`
			conn=`su -c 'echo "SELECT count(*) FROM pg_stat_activity;"|psql' postgres | tail -3 | head -1`

			if [ -z "$conn" ]; then
                        	err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 53300 -eq $err ]; then
                                        conn="-1"
                                fi
                        fi
			rm -rf /tmp/err
			echo '{"code":5000,"success":"true","message":"Current PostgreSql Threads Connected","Threads Connected":"'$conn'"}'
		else
			echo '{"success":"false","code":3001, "message":"Current PostgreSql Threads Connected Could Not Be Fetch, Due To PostgreSql Not Running"}'
		fi
        ;;

get.system.load)
	load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
        echo '{"code":5000,"success":"true","message":"Current System Load Average","Load Avg":"'$load'"}'
        ;;


get.postgres.max.connection)
		d=`netstat -npl|grep postmaster|grep 5432|head -1|rev|awk '{print $1}'|rev|cut -d"/" -f1`
		/bin/echo "d=$d"
		if [ ! -z $d ]; then
                        max_conn=`cat /var/lib/pgsql/9.6/data/postgresql.conf | grep "max_connections"|awk '{print $3}'`
			echo '{"code":5000,"success":"true","message":"Current Max Connection Set on PostgreSql","Max Connection":"'$max_conn'"}'
		else
			echo '{"success":"false","code":3001, "message":"Current Max Connection Set on postgres Could Not Be Fetch, Due To PostgreSql Not Running"}'
		fi
        ;;


get.current.master)

	master=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep master|cut -d "=" -f2|awk '{print $1}'`
        if [ ! -z $master ]; then
                echo '{"code":5000,"success":"true","message":"Current PostgreSql Master","Master":"'$master'"}'
        else
                        echo '{"success":"false","code":3001, "message":"We Cannot Find PostgreSql Master"}'
               

        fi
        ;;


get.current.slave)
	slave=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep standby|cut -d "=" -f2|awk '{print $1}'`
        if [ ! -z $slave ]; then
                echo '{"code":5000,"success":"true","message":"Current PostgreSql Slave","Slave":"'$slave'"}'
        	
		else
                        echo '{"success":"false","code":3001, "message":"We Cannot Find PostgreSql Slave"}'
                
        fi
        ;;

get.failover.agent.status)
	slave=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep standby|cut -d "=" -f2|awk '{print $1}'`

	repmgr_pid=`ssh -i $HOME/.ssh/id_rsa root@$slave ps aux |grep repmgrd|grep -v grep|awk '{print $2}'`
	echo "repmgr_pid = $repmgr_pid"
        if [ ! -z $repmgr_pid ]; then
                echo '{"code":5000,"success":"true","message":"RepMgrD Process Is Running"}'
	else
        	echo '{"success":"false","code":3001, "message":"RepMgrD Process Is Not Running"}'
        fi
        ;;


run.failover)
	
	master=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep master|cut -d "=" -f2|awk '{print $1}'`
	slave=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep standby|cut -d "=" -f2|awk '{print $1}'`
	repmgr_pid=`ssh -i $HOME/.ssh/id_rsa root@$slave ps aux |grep repmgrd|grep -v grep|awk '{print $2}'`
        if [ ! -z $repmgr_pid ]; then
		ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -F
		ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -F
		ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
		ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/postgresql-9.6 restart
		pg_current_xlog_location=`ssh -i /root/.ssh/id_rsa root@$master "su -c 'echo \"SELECT pg_current_xlog_location();\"|psql' postgres|head -3 |tail -1"`
		pg_last_xlog_receive_location=`ssh -i /root/.ssh/id_rsa root@$slave "su -c 'echo \"SELECT pg_last_xlog_receive_location();\"|psql' postgres|head -3 |tail -1"`
		pg_current_xlog_location1=`echo $pg_current_xlog_location|cut -d "/" -f1`
		pg_current_xlog_location2=`echo $pg_current_xlog_location|cut -d "/" -f2`
		pg_last_xlog_receive_location1=`echo $pg_last_xlog_receive_location|cut -d "/" -f1`
		pg_last_xlog_receive_location2=`echo $pg_last_xlog_receive_location|cut -d "/" -f2`
		count=1
       		while [ $count -lt 16 ]; do
			if [ $pg_current_xlog_location1 -eq $pg_last_xlog_receive_location1 ]; then
				if [ $pg_current_xlog_location2 == $pg_last_xlog_receive_location2 ]; then
					echo "Replication Delay 0"
					count=17
					replication_delay=0
					ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
	                                ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/postgresql-9.6 stop
				else
			                echo "Plz Wait While Replication Done"
					replication_delay=1
			                count=$((count+1))
				fi
			else
				echo "Replication Is Too Delay, Plz Wait While Replication Done"
				replication_delay=0
			fi
		sleep 30
		done
		if [ $replication_delay != 0 ]; then
			ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
	        	ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
			ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
			ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 5432 --to-destination $master:5432
			ssh -i /root/.ssh/id_rsa root@10.20.1.5 /etc/init.d/iptables save
			ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
                        ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 5432 --to-destination $master:5432
			ssh -i /root/.ssh/id_rsa root@10.20.1.6 /etc/init.d/iptables save
		        echo '{"success":"false","code":3001, "message":"PostgreSQL Failover Could Not Be Run Due To Long Repliction Delay"}'
			exit 1
		fi
       	count=1
        while [ $count -lt 16 ]; do
                new_master=`ssh -i /root/.ssh/id_rsa root@"$slave" cat /var/lib/pgsql/repmgr/repmgr.log |grep 'STANDBY PROMOTE successful'|tail -1|cut -d':' -f2`
                if [ -n "$new_master" ]; then
                        count=17
                        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
                        ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
                        echo '{"code":5000,"success":"true","message":"PostgreSQL Failover Completed Successfully","New Master":"'$slave'"}'
                        exit 0
                else
                        count=$((count+1))
                        sleep 30
                fi
        done
	else

	        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
        	ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
		ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        	ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 5432 --to-destination $master:5432
	        ssh -i /root/.ssh/id_rsa root@10.20.1.5 /etc/init.d/iptables save
        	ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	        ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 5432 --to-destination $master:5432
		ssh -i /root/.ssh/id_rsa root@10.20.1.6 /etc/init.d/iptables save
	        echo '{"success":"false","code":3001, "message":"PostgreSql Failover Could Not Be Succeed"}'
	fi
        ;;

update.max.connection)
	master=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep master|cut -d "=" -f2|awk '{print $1}'`
        slave=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep standby|cut -d "=" -f2|awk '{print $1}'`
	con=`cat /var/lib/pgsql/9.6/data/postgresql.conf | grep "max_connections"|awk '{print $3}'`
        ssh -i /root/.ssh/id_rsa root@"$master" sed -ie "s/max_connections = $con/max_connections = $2/g" /var/lib/pgsql/9.6/data/postgresql.conf
        ssh -i /root/.ssh/id_rsa root@"$slave" sed -ie "s/max_connections = $con/max_connections = $2/g" /var/lib/pgsql/9.6/data/postgresql.conf
        con_stat=`cat /var/lib/pgsql/9.6/data/postgresql.conf | grep "max_connections"|awk '{print $3}'`
        if [ $2 -eq $con_stat ]; then
		ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/postgresql-9.6 restart
		ssh -i /root/.ssh/id_rsa root@"$slave" /etc/init.d/postgresql-9.6 restart
                echo '{"code":5000,"success":"true","message":"PostgreSql Max Connection Update Successfully","New Max Connection":"'$2'"}'
       	else
                echo '{"success":"false","code":3001, "message":"PostgreSql Max Connection Updation Failed"}'
        fi
        ;;

#update.my.cnf)
#        con=`cat /etc/my.cnf|grep max_connections`
#        sed -ie "s/$con/max_connections = $2/g" /etc/my.cnf
#        con_stat=`cat /etc/my.cnf|grep max_connections|awk '{print $3}'`
#	idb_pool=`cat /etc/my.cnf|grep innodb_buffer_pool_size`
#        sed -ie "s/$idb_pool/innodb_buffer_pool_size = $3M/g" /etc/my.cnf
#        idb_pool_stat=`cat /etc/my.cnf|grep innodb_buffer_pool_size|awk '{print $3}'`
#        if [ $2 -eq $con_stat ] && [ "$3"'M' == $idb_pool_stat ]; then
#		exit 0
#   	else
#		exit 1
#        fi
#        ;;

#update.buffer.pool)
#        idb_pool=`cat /etc/my.cnf|grep innodb_buffer_pool_size`
#        sed -ie "s/$idb_pool/innodb_buffer_pool_size = $2M/g" /etc/my.cnf
#        idb_pool_stat=`cat /etc/my.cnf|grep innodb_buffer_pool_size|awk '{print $3}'`
#        if [ "$2"'M' == $idb_pool_stat ]; then
#                echo '{"code":5000,"success":"true","message":"MySql Innodb Buffer Pool Size Update Successfully","New Innodb Buffer Pool Size":"'$2'"}'
#        else
#                echo '{"success":"false","code":3001, "message":"MySql Innodb Buffer Pool Size Updation Failed"}'
#        fi
#        ;;

get.slave.status)
#        mysql_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
#        if [ 10.20.1.7 == $mysql_ip ]; then
#                ip="10.20.1.8"
#        else
#                ip="10.20.1.7"
#        fi
##        if [ -f /var/lib/mysql/mysql/relay-log.info ]; then
#                slave_status=`mysql -u root -pApp42ShepAdmin  -e 'show slave status \G;'| grep "Seconds_Behind_Master"|awk '{print $2}'`
		slave_status="0"
#                if [ ! -z "$slave_status" ] && [ NULL != $slave_status ]; then
                        echo '{"code":5000,"success":"true","message":"Current PostgreSql Slave Status","Seconds Behind Master":"'$slave_status'"}'
#                else
#			sleep 1
#                        echo '{"success":"false","code":3001, "message":"Current MySql Slave Status Could Not Be Fetch, Due To Mysql Not Running"}'
#                fi
#        else
#                ssh -i /root/.ssh/id_rsa root@"$ip" /app42RDS/sbin/agent int.get.slave.status
#        fi
        ;;

update.user.password)
	username=$2
	old_password=$3
	new_password=$4
	master=`su -c  "/usr/pgsql-9.6/bin/repmgr -f /etc/repmgr/repmgr.conf cluster show" postgres|grep master|cut -d "=" -f2|awk '{print $1}'`
	ssh -i /root/.ssh/id_rsa root@"$master" /app42RDS/sbin/agent reset.password $2 $3 $4
	;;
reset.password)
	username=$2
        old_password=$3
        new_password=$4
	su -c 'echo "ALTER USER '$username' WITH PASSWORD '"'$new_password'"';"|/usr/bin/psql' postgres > /tmp/reset_pwd
	alt=`cat /tmp/reset_pwd`
        if [ "$alt" == "ALTER ROLE" ]; then
		echo '{"code":5000,"success":"true","message":"PostgreSql User Password Update Successfully"}'
	else
		echo '{"success":"false","code":3001, "message":"Current PostgreSql User Password Could Not Be Update"}'
	fi
	;;

#processlist)
#	process=`mysqladmin -u App42RootUser -pApp42MySQLAdmin processlist`
#	if [ $? -eq 0 ]; then
#		echo '{"code":5000,"success":"true","message":"Current MySql Processlist","Processlist":"'$process'"}'
#	else
#		echo '{"success":"false","code":3001, "message":"Current MySql Processlist Could Not Be Fetch, Due To Mysql Not Running"}'
#	fi
#	;;

flush.iptables)
	ssh -i /root/.ssh/id_rsa root@"$2" iptables -t nat -F
	ssh -i /root/.ssh/id_rsa root@"$3" iptables -t nat -F
	if [ $? -eq 0 ]; then
                echo "Iptables Reset"
        else
		echo "Iptables Reset Failed"
        fi
        ;;

#master.reset)
#	rm -rf /var/lib/mysql/mysql/auto.cnf
#	rm -rf /var/lib/mysql/mysql/master.info
#	rm -rf /var/lib/mysql/mysql/relay-log.info
#	rm -rf /var/lib/mysql/mysql-binlog/*
#	rm -rf /var/lib/mysql/logs/*
#	touch /var/lib/mysql/logs/mysqld.log
#        touch /var/lib/mysql/logs/mysql-slow.log
#        chown -R mysql.mysql /var/lib/mysql/logs/*
#	/etc/init.d/mysqld restart
#	sleep 10
#	echo "RESET SLAVE;"|mysql -u root -pApp42ShepAdmin
#	echo "RESET MASTER;"|mysql -u root -pApp42ShepAdmin
#	if [ $? -eq 0 ]; then
#		echo "show master status \G;"|mysql -u root -pApp42ShepAdmin > /tmp/restore_master_position
#                echo "Mysql Master Reset"
#        else
#                echo "Mysql Master Reset Failed"
#        fi
#        ;;

set.iptables)
	ssh -i /root/.ssh/id_rsa root@"$2" iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	ssh -i /root/.ssh/id_rsa root@"$2" iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 3306 --to-destination $4:3306
        ssh -i /root/.ssh/id_rsa root@"$3" iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	ssh -i /root/.ssh/id_rsa root@"$3" iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 3306 --to-destination $4:3306
        if [ $? -eq 0 ]; then
                echo "Iptables Set"
        else
                echo "Iptables Set Failed"
        fi
        ;;
	
#restore.change.master)
#	rm -rf /var/lib/mysql/mysql/auto.cnf
#        rm -rf /var/lib/mysql/mysql/master.info
#        rm -rf /var/lib/mysql/mysql/relay-log.info
#        rm -rf /var/lib/mysql/mysql-binlog/*
#        rm -rf /var/lib/mysql/logs/*
#	touch /var/lib/mysql/logs/mysqld.log
#	touch /var/lib/mysql/logs/mysql-slow.log
#	chown -R mysql.mysql /var/lib/mysql/logs/*
#	/etc/init.d/mysqld restart
#	echo "STOP SLAVE;"|mysql -u root -pApp42ShepAdmin
#        echo "RESET SLAVE;"|mysql -u root -pApp42ShepAdmin
#        echo "RESET MASTER;"|mysql -u root -pApp42ShepAdmin
#	echo "CHANGE MASTER TO MASTER_HOST = '10.20.1.7', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='mysqld-bin.000001', MASTER_LOG_POS=$2;"|mysql -u root -pApp42ShepAdmin
#	echo "FLUSH PRIVILEGES;"|mysql -u root -pApp42ShepAdmin
#        echo "start slave;"|mysql -u root -pApp42ShepAdmin
#	if [ $? -eq 0 ]; then
#                echo "Change Master Set, Slave Start Syncing"
 #       else
#                echo "Change Master Set Failed"
#        fi
#        ;;



esac

