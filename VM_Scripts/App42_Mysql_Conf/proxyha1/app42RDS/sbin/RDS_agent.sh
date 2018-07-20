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

get.mysqlvm.info)
                d=`netstat -npl|grep mysqld|grep 3306|rev|awk '{print $1}'|rev|cut -d"/" -f1`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        used_cpu=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
                        echo 1 > /proc/sys/vm/drop_caches
                        total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`
                        used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
                        mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
			dsk=`df  -T|grep "/var/lib/mysql"|awk '{print $3}'`
			disk_MB=`echo "$dsk / 1000 + 50"|bc`
			load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
                        conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                        conn=`echo $conn_stat|grep "Threads_connected"|awk '{print $8}'`
                        cache=`echo $conn_stat|grep "Threads_cached"|awk '{print $6}'`
                        max_conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW VARIABLES LIKE "max_connections"' 2> /tmp/err1`
                        max_conn=`echo $max_conn_stat|grep "max_connections"|awk '{print $4}'`
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
                        echo '{"code":5000,"success":"true","message":"Current Mysql VM Info", "CPU":"'$used_cpu'", "Memory":"'$mem_percent'", "Load Avg":"'$load'", "Threads Connected":"'$conn'", "Threads Cached":"'$cache'", "Max Connection":"'$max_conn'", "Used Data Disk":"'$disk_MB'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Mysql VM Info Could Not Be Fetch, Due To Mysql Not Running"}'
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

get.mysql.connection)
		d=`netstat -npl|grep mysqld|grep 3306|rev|awk '{print $1}'|rev|cut -d"/" -f1`
		/bin/echo "d=$d"
		if [ ! -z $d ]; then
			conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                        conn=`echo $conn_stat|grep "Threads_connected"|awk '{print $8}'`
			if [ -z "$conn_stat" ]; then
                        	err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 1040 -eq $err ]; then
                                        conn="-1"
                                fi
                        fi
			rm -rf /tmp/err
			echo '{"code":5000,"success":"true","message":"Current MySql Threads Connected","Threads Connected":"'$conn'"}'
		else
			echo '{"success":"false","code":3001, "message":"Current MySql Threads Connected Could Not Be Fetch, Due To Mysql Not Running"}'
		fi
        ;;

get.system.load)
	load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
        echo '{"code":5000,"success":"true","message":"Current System Load Average","Load Avg":"'$load'"}'
        ;;

get.mysql.threads.cached)
		d=`netstat -npl|grep mysqld|grep 3306|rev|awk '{print $1}'|rev|cut -d"/" -f1`
		/bin/echo "d=$d"
		if [ ! -z $d ]; then
			conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                        cache=`echo $conn_stat|grep "Threads_cached"|awk '{print $6}'`
			if [ -z "$conn_stat" ]; then
                                err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 1040 -eq $err ]; then
                                        cache="-1"
                                fi
                        fi
                        rm -rf /tmp/err
			echo '{"code":5000,"success":"true","message":"Current MySql Threads Cached","Threads Cached":"'$cache'"}'
		else
			echo '{"success":"false","code":3001, "message":"Current MySql Threads Cached Could Not Be Fetch, Due To Mysql Not Running"}'
		fi
        ;;

get.mysql.max.connection)
		d=`netstat -npl|grep mysqld|grep 3306|rev|awk '{print $1}'|rev|cut -d"/" -f1`
		/bin/echo "d=$d"
		if [ ! -z $d ]; then
			max_conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW VARIABLES LIKE "max_connections"' 2> /tmp/err`
                        max_conn=`echo $max_conn_stat|grep "max_connections"|awk '{print $4}'`
                        if [ -z "$max_conn_stat" ]; then
                                err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 1040 -eq $err ]; then
                                        max_conn="-1"
                                fi
                        fi
                        rm -rf /tmp/err
			echo '{"code":5000,"success":"true","message":"Current Max Connection Set on MySql","Max Connection":"'$max_conn'"}'
		else
			echo '{"success":"false","code":3001, "message":"Current Max Connection Set on MySql Could Not Be Fetch, Due To Mysql Not Running"}'
		fi
        ;;


get.current.master)
        proxy_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
        if [ 10.20.1.5 == $proxy_ip ]; then
                ip="10.20.1.6"
        else
                ip="10.20.1.5"
        fi

        mha=`ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
        if [ ! -z $mha ]; then
                master=`cat /var/log/masterha/master-mysql/*.master_status.health|cut -d":" -f3`
                echo '{"code":5000,"success":"true","message":"Current MySql Master","Master":"'$master'"}'
        else
                mha=`ssh -i /root/.ssh/id_rsa root@"$ip" ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
                if [ ! -z $mha ]; then
                        master=`ssh -i /root/.ssh/id_rsa root@"$ip" cat /var/log/masterha/master-mysql/*.master_status.health|cut -d":" -f3`
                        echo '{"code":5000,"success":"true","message":"Current MySql Master","Master":"'$master'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Not Running MHA On Any Proxy, We Can Not Find MySql Master"}'
                fi

        fi
        ;;


get.current.slave)
        proxy_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
        if [ 10.20.1.5 == $proxy_ip ]; then
                ip="10.20.1.6"
        else
                ip="10.20.1.5"
        fi

        mha=`ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
        if [ ! -z $mha ]; then
                master=`cat /var/log/masterha/master-mysql/*.master_status.health|cut -d":" -f3`
                if [ 10.20.1.7 == $master ]; then
                        slave="10.20.1.8"
                else
                        slave="10.20.1.7"
                fi
                echo '{"code":5000,"success":"true","message":"Current MySql Slave","Slave":"'$slave'"}'
        else
                mha=`ssh -i /root/.ssh/id_rsa root@"$ip" ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
                if [ ! -z $mha ]; then
                        master=`ssh -i /root/.ssh/id_rsa root@"$ip" cat /var/log/masterha/master-mysql/*.master_status.health|cut -d":" -f3`
                        if [ 10.20.1.7 == $master ]; then
                                slave="10.20.1.8"
                        else
                                slave="10.20.1.7"
                        fi
                        echo '{"code":5000,"success":"true","message":"Current MySql Slave","Slave":"'$slave'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Not Running MHA On Any Proxy, We Can Not Find MySql Slave"}'
                fi

        fi
        ;;

get.mha.status)
        proxy_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
        if [ 10.20.1.5 == $proxy_ip ]; then
                ip="10.20.1.6"
        else
                ip="10.20.1.5"
        fi

        mha=`ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
        if [ ! -z $mha ]; then
                echo '{"code":5000,"success":"true","message":"MHA Process Is Running"}'
        else
                mha=`ssh -i /root/.ssh/id_rsa root@"$ip" ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
                if [ ! -z $mha ]; then
                        echo '{"code":5000,"success":"true","message":"MHA Process Is Running"}'
                else
                        echo '{"success":"false","code":3001, "message":"MHA Process Is Not Running"}'
                fi
        fi
        ;;


run.failover)
        proxy_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
        if [ 10.20.1.5 == $proxy_ip ]; then
                ip="10.20.1.6"
        else
                ip="10.20.1.5"
        fi

        mha=`ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
        if [ ! -z $mha ]; then
                mha_ip=`ip \r|grep src|rev|awk '{print $1}'|rev`
                master=`cat /var/log/masterha/master-mysql/*.master_status.health|cut -d":" -f3`
        else
                mha_ip=`ssh -i /root/.ssh/id_rsa root@"$ip" ip \r|grep src|rev|awk '{print $1}'|rev`
                mha=`ssh -i /root/.ssh/id_rsa root@"$ip" ps aux|grep masterha_manager|grep -v grep|head -1|awk '{print $2}'`
                if [ ! -z $mha ]; then
                        master=`ssh -i /root/.ssh/id_rsa root@"$ip" cat /var/log/masterha/master-mysql/*.master_status.health|cut -d":" -f3`
                else
                        echo '{"success":"false","code":3001, "message":"Not Running MHA On Any Proxy, We Can Not Run MySql Failover"}'
                        exit 1
                fi

        fi

        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
        ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/mysqld stop
        count=1
        while [ $count -lt 16 ]; do
                new_master=`ssh -i /root/.ssh/id_rsa root@"$mha_ip" cat /var/log/masterha/master-mysql/master-mysql.log |grep 'completed successfully'|tail -1|cut -d'(' -f1|rev|awk '{print $1}'|rev`
                if [ -n "$new_master" ]; then
                        count=17
                        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
                        ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
                        echo '{"code":5000,"success":"true","message":"MySql Failover Completed Successfully","New Master":"'$new_master'"}'
                        exit 0
                else
                        count=$((count+1))
                        sleep 30
                fi
        done
        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
        ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
        echo '{"success":"false","code":3001, "message":"MySql Failover Could Not Be Succeed"}'
        ;;

update.max.connection)
        mysql_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
        if [ 10.20.1.7 == $mysql_ip ]; then
                ip="10.20.1.8"
        else
                ip="10.20.1.7"
        fi
        con=`cat /etc/my.cnf|grep max_connections`
        sed -ie "s/$con/max_connections = $2/g" /etc/my.cnf
        con_stat=`cat /etc/my.cnf|grep max_connections|awk '{print $3}'`
        if [ $2 -eq $con_stat ]; then
                ssh -i /root/.ssh/id_rsa root@"$ip" /app42RDS/sbin/agent int.update.max.connection $2
                mysql -u root -pApp42ShepAdmin  -e 'SET GLOBAL max_connections = '$2';'
                if [ $? -eq 0 ]; then
			/etc/init.d/mysqld restart
                        echo '{"code":5000,"success":"true","message":"MySql Max Connection Update Successfully","New Max Connection":"'$2'"}'
                else
			count=0
                        while [ $count -lt 2 ]; do
                                mysql -u root -pApp42ShepAdmin  -e 'SET GLOBAL max_connections = '$2';'
                                if [ $? -eq 0 ]; then
                                        echo "New Connection Set $2"
                                        count=3
                                else
                                        count=$((count+1))
                                fi
                                if [ $count -eq 3 ]; then
                                        /etc/init.d/mysqld restart
                                fi
                        done
                        echo '{"code":5000,"success":"true","message":"MySql Max Connection Update Successfully","New Max Connection":"'$2'"}'
#                        echo '{"success":"false","code":3001, "message":"MySql Max Connection Updation Failed"}'
                fi
        else
                echo '{"success":"false","code":3001, "message":"MySql Max Connection Updation Failed"}'
        fi
        ;;

int.update.max.connection)
        con=`cat /etc/my.cnf|grep max_connections`
        sed -ie "s/$con/max_connections = $2/g" /etc/my.cnf
        con_stat=`cat /etc/my.cnf|grep max_connections|awk '{print $3}'`
        if [ $2 -eq $con_stat ]; then
                mysql -u root -pApp42ShepAdmin  -e 'SET GLOBAL max_connections = '$2';'
                if [ $? -eq 0 ]; then
                        my_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
			/etc/init.d/mysqld restart
                        echo "MySql Max Connection Update Successfully On $my_ip"
                else
			count=0
                        while [ $count -lt 2 ]; do
                                mysql -u root -pApp42ShepAdmin  -e 'SET GLOBAL max_connections = '$2';'
                                if [ $? -eq 0 ]; then
                                        echo "New Connection Set $2"
                                        count=3
                                else
                                        count=$((count+1))
                                fi
                                if [ $count -eq 3 ]; then
                                        /etc/init.d/mysqld restart
                                fi
                        done
                        my_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
                        echo "MySql Max Connection Update Successfully On $my_ip"
#                        echo "MySql Max Connection Updation Failed On $my_ip"
                fi
        else
                echo "MySql Max Connection Updation Failed On $my_ip"
        fi
        ;;

update.my.cnf)
        con=`cat /etc/my.cnf|grep max_connections`
        sed -ie "s/$con/max_connections = $2/g" /etc/my.cnf
        con_stat=`cat /etc/my.cnf|grep max_connections|awk '{print $3}'`
	idb_pool=`cat /etc/my.cnf|grep innodb_buffer_pool_size`
        sed -ie "s/$idb_pool/innodb_buffer_pool_size = $3M/g" /etc/my.cnf
        idb_pool_stat=`cat /etc/my.cnf|grep innodb_buffer_pool_size|awk '{print $3}'`
        if [ $2 -eq $con_stat ] && [ "$3"'M' == $idb_pool_stat ]; then
		exit 0
   	else
		exit 1
        fi
        ;;

update.buffer.pool)
        idb_pool=`cat /etc/my.cnf|grep innodb_buffer_pool_size`
        sed -ie "s/$idb_pool/innodb_buffer_pool_size = $2M/g" /etc/my.cnf
        idb_pool_stat=`cat /etc/my.cnf|grep innodb_buffer_pool_size|awk '{print $3}'`
        if [ "$2"'M' == $idb_pool_stat ]; then
                echo '{"code":5000,"success":"true","message":"MySql Innodb Buffer Pool Size Update Successfully","New Innodb Buffer Pool Size":"'$2'"}'
        else
                echo '{"success":"false","code":3001, "message":"MySql Innodb Buffer Pool Size Updation Failed"}'
        fi
        ;;

get.slave.status)
        mysql_ip=`ip \r|grep src|grep "10.20.1.0/25"|rev|awk '{print $1}'|rev`
        if [ 10.20.1.7 == $mysql_ip ]; then
                ip="10.20.1.8"
        else
                ip="10.20.1.7"
        fi
        if [ -f /var/lib/mysql/mysql/relay-log.info ]; then
                slave_status=`mysql -u root -pApp42ShepAdmin  -e 'show slave status \G;'| grep "Seconds_Behind_Master"|awk '{print $2}'`
                if [ ! -z "$slave_status" ] && [ NULL != $slave_status ]; then
                        echo '{"code":5000,"success":"true","message":"Current MySql Slave Status","Seconds Behind Master":"'$slave_status'"}'
                else
			sleep 1
                        echo '{"success":"false","code":3001, "message":"Current MySql Slave Status Could Not Be Fetch, Due To Mysql Not Running"}'
                fi
        else
                ssh -i /root/.ssh/id_rsa root@"$ip" /app42RDS/sbin/agent int.get.slave.status
        fi
        ;;

int.get.slave.status)
        slave_status=`mysql -u root -pApp42ShepAdmin  -e 'show slave status \G;'| grep "Seconds_Behind_Master"|awk '{print $2}'`
        if [ ! -z "$slave_status" ] && [ NULL != $slave_status ]; then
                echo '{"code":5000,"success":"true","message":"Current MySql Slave Status","Seconds Behind Master":"'$slave_status'"}'
        else
                sleep 1
                echo '{"success":"false","code":3001, "message":"Current MySql Slave Status Could Not Be Fetch, Due To Mysql Not Running"}'
        fi
        ;;
update.user.password)
	username=$2
	old_password=$3
	new_password=$4
#	new_password=`openssl rand -base64 10`
	echo "SET PASSWORD FOR '$username'@'%' = PASSWORD('$new_password');"|mysql -u root -pApp42ShepAdmin
	if [ $? -eq 0 ]; then
		echo '{"code":5000,"success":"true","message":"MySql User Password Update Successfully"}'
	else
		echo '{"success":"false","code":3001, "message":"Current MySql User Password Could Not Be Update"}'
	fi
	;;

processlist)
	process=`mysqladmin -u App42RootUser -pApp42MySQLAdmin processlist`
	if [ $? -eq 0 ]; then
		echo '{"code":5000,"success":"true","message":"Current MySql Processlist","Processlist":"'$process'"}'
	else
		echo '{"success":"false","code":3001, "message":"Current MySql Processlist Could Not Be Fetch, Due To Mysql Not Running"}'
	fi
	;;

flush.iptables)
	ssh -i /root/.ssh/id_rsa root@"$2" iptables -t nat -F
	ssh -i /root/.ssh/id_rsa root@"$3" iptables -t nat -F
	if [ $? -eq 0 ]; then
                echo "Iptables Reset"
        else
		echo "Iptables Reset Failed"
        fi
        ;;

master.reset)
	rm -rf /var/lib/mysql/mysql/auto.cnf
	rm -rf /var/lib/mysql/mysql/master.info
	rm -rf /var/lib/mysql/mysql/relay-log.info
	rm -rf /var/lib/mysql/mysql-binlog/*
	rm -rf /var/lib/mysql/logs/*
	touch /var/lib/mysql/logs/mysqld.log
        touch /var/lib/mysql/logs/mysql-slow.log
        chown -R mysql.mysql /var/lib/mysql/logs/*
	/etc/init.d/mysqld restart
	sleep 10
	echo "RESET SLAVE;"|mysql -u root -pApp42ShepAdmin
	echo "RESET MASTER;"|mysql -u root -pApp42ShepAdmin
	if [ $? -eq 0 ]; then
		echo "show master status \G;"|mysql -u root -pApp42ShepAdmin > /tmp/restore_master_position
                echo "Mysql Master Reset"
        else
                echo "Mysql Master Reset Failed"
        fi
        ;;

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
	
restore.change.master)
	rm -rf /var/lib/mysql/mysql/auto.cnf
        rm -rf /var/lib/mysql/mysql/master.info
        rm -rf /var/lib/mysql/mysql/relay-log.info
        rm -rf /var/lib/mysql/mysql-binlog/*
        rm -rf /var/lib/mysql/logs/*
	touch /var/lib/mysql/logs/mysqld.log
	touch /var/lib/mysql/logs/mysql-slow.log
	chown -R mysql.mysql /var/lib/mysql/logs/*
	/etc/init.d/mysqld restart
	echo "STOP SLAVE;"|mysql -u root -pApp42ShepAdmin
        echo "RESET SLAVE;"|mysql -u root -pApp42ShepAdmin
        echo "RESET MASTER;"|mysql -u root -pApp42ShepAdmin
	echo "CHANGE MASTER TO MASTER_HOST = '10.20.1.7', MASTER_PORT = 3306, MASTER_USER = 'slave_user', MASTER_PASSWORD = 'App42RDSSlavePawword', MASTER_LOG_FILE='mysqld-bin.000001', MASTER_LOG_POS=$2;"|mysql -u root -pApp42ShepAdmin
	echo "FLUSH PRIVILEGES;"|mysql -u root -pApp42ShepAdmin
        echo "start slave;"|mysql -u root -pApp42ShepAdmin
	if [ $? -eq 0 ]; then
                echo "Change Master Set, Slave Start Syncing"
        else
                echo "Change Master Set Failed"
        fi
        ;;



esac

