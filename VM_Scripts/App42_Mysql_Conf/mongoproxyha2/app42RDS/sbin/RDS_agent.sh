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

get.mongo.info)
                d=`ps ax |grep mongod|grep -v grep |grep -v dhclient|awk '{print $1}'`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        used_cpu=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
                        echo 1 > /proc/sys/vm/drop_caches
                        total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`
                        used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
                        mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
                        dsk=`df  -T|grep "/var/lib/mongo"|awk '{print $3}'`
                        disk_MB=`echo "$dsk / 1000 + 50"|bc`
                        load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
                       #conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                       # conn=`echo $conn_stat|grep "Threads_connected"|awk '{print $8}'`
                        conn=`echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep current|cut -d":" -f2|cut -d "," -f1`
                        avil=`echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep available|cut -d":" -f3|cut -d "," -f1`
                        max_conn=`echo "$conn + $avil"|bc`
                       #cache=`echo $conn_stat|grep "Threads_cached"|awk '{print $6}'`
                       #max_conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW VARIABLES LIKE "max_connections"' 2> /tmp/err1`
                       #max_conn=`echo $max_conn_stat|grep "max_connections"|awk '{print $4}'`
                        if [ -z "$conn" ]; then
                                err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 1040 -eq $err ]; then
                                        conn="-1"
                                        cache="-1"
                                fi
                        fi
                        if [ -z "$max_conn" ]; then
                                err=`cat /tmp/err1 |grep "ERROR"|awk '{print $2}'`
                                if [ 1040 -eq $err ]; then
                                        max_conn="-1"
                                fi
                        fi
                        rm -rf /tmp/err /tmp/err1
                        echo '{"code":5000,"success":"true","message":"Current Mongo VM Info", "CPU":"'$used_cpu'", "Memory":"'$mem_percent'", "Load Avg":"'$load'", "Threads Connected":"'$conn'", "Max Connection":"'$max_conn'", "Used Data Disk":"'$disk_MB'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Mongo VM Info Could Not Be Fetch, Due To Mongo Not Running"}'
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

get.mongo.connection)
                d=`ps ax |grep mongod|grep -v grep |grep -v dhclient|awk '{print $1}'`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        conn=`echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep current|cut -d":" -f2|cut -d "," -f1`
                        if [ -z "$conn" ]; then
                                conn="-1"
                        fi
                        echo '{"code":5000,"success":"true","message":"Current MongoDB Threads Connected","Threads Connected":"'$conn'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current MongoDB Threads Connected Could Not Be Fetch, Due To MongoDB Not Running"}'
                fi
        ;;

get.system.load)
        load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
        echo '{"code":5000,"success":"true","message":"Current System Load Average","Load Avg":"'$load'"}'
        ;;


get.mongo.max.connection)
                d=`ps ax |grep mongod|grep -v grep |grep -v dhclient|awk '{print $1}'`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        conn=`echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep current|cut -d":" -f2|cut -d "," -f1`
                        avil=`echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep available|cut -d":" -f3|cut -d "," -f1`
                        max_conn=`echo "$conn + $avil"|bc`
                        echo '{"code":5000,"success":"true","message":"Current Max Connection Set on MongoDB","Max Connection":"'$max_conn'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Max Connection Set on MongoDB Could Not Be Fetch, Due To MongoDB Not Running"}'
                fi
        ;;


get.current.master)

        master=`mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1`
        if [ ! -z $master ]; then
                echo '{"code":5000,"success":"true","message":"Current MongoDB Master","Master":"'$master'"}'
        else
                echo '{"success":"false","code":3001, "message":"We Cannot Find MongoDB Master"}'


        fi
        ;;


get.current.slave)
        master=`mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1`
        if [ 10.20.1.7 == $master ]; then
                slave="10.20.1.8"
        else
                slave="10.20.1.7"
        fi
        nc -zv $slave 27017
        if [ $? -eq 0 ]; then
                echo '{"code":5000,"success":"true","message":"Current MongoDB Slave","Slave":"'$slave'"}'

                else
                 echo '{"success":"false","code":3001, "message":"We Cannot Find MongoDB Slave"}'

        fi
        ;;

get.failover.agent.status)
        master=`mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1`
        if [ 10.20.1.7 == $master ]; then
                slave="10.20.1.8"
        else
                slave="10.20.1.7"
        fi
        nc -zv $slave 27017
        slave_val=$?
        nc -zv 10.20.1.5 37017
        arb_val=$?
        if [ $slave_val -eq 0 ] && [ $arb_val -eq 0 ]; then
                echo '{"code":5000,"success":"true","message":"MongoDB Slave & Arbiter Process Is Running"}'
        else
                echo '{"success":"false","code":3001, "message":"MongoDB Slave & Arbiter Process Is Not Running"}'
        fi
        ;;



run.failover)
        master=`ssh -i /root/.ssh/id_rsa root@10.20.1.7 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        if [ -z $master ]; then
                master=`ssh -i /root/.ssh/id_rsa root@10.20.1.8 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        fi
        if [ 10.20.1.7 == $master ]; then
                slave="10.20.1.8"
                master_id=0
                slave_id=1
        else
                slave="10.20.1.7"
                master_id=1
                slave_id=0
        fi
        nc -zv $master 27017
        master_val=$?
        nc -zv $slave 27017
        slave_val=$?
        nc -zv 10.20.1.5 37017
        arb_val=$?
        if [ $master_val -ne 0 ] && [ $slave_val -ne 0 ] && [ $arb_val -ne 0 ]; then
                echo '{"success":"false","code":3001, "message":"Not Running Sentinel On Any VM, We Can Not Run MongoDB Failover"}'
                exit 1
        fi

	ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -F
	ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -F

        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
        ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/mongod stop
        count=1
        while [ $count -lt 16 ]; do
                new_master=`ssh -i /root/.ssh/id_rsa root@$slave 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
                if [ ! -z $new_master ]; then
                        count=17
                        ssh -i /root/.ssh/id_rsa root@$slave "echo 'cfg = rs.conf(); cfg.members[$slave_id].priority = 2; cfg.members[$master_id].priority = 1; rs.reconfig(cfg);'|mongo admin -u admin -p App42MongoRDSDBaaS"
                        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
                        ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
                        ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/mongod start
			ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
			ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 27017 --to-destination $slave:27017
			ssh -i /root/.ssh/id_rsa root@10.20.1.5 /etc/init.d/iptables save
			ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
			ssh -i /root/.ssh/id_rsa root@10.20.1.6 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 27017 --to-destination $slave:27017
			ssh -i /root/.ssh/id_rsa root@10.20.1.6 /etc/init.d/iptables save
			/app42RDS/sbin/mail qwertyuiop $slave
                        echo '{"code":5000,"success":"true","message":"MongoDB Failover Completed Successfully","New Master":"'$slave'"}'
                        exit 0
                else
                        count=$((count+1))
                        sleep 30
                fi
        done
        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
        ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
        ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/mongod start
        echo '{"success":"false","code":3001, "message":"MongoDB Failover Could Not Be Succeed"}'
        ;;

update.max.connection)
        master=`ssh -i /root/.ssh/id_rsa root@10.20.1.7 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        if [ -z $master ]; then
                master=`ssh -i /root/.ssh/id_rsa root@10.20.1.8 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        fi
        if [ 10.20.1.7 == $master ]; then
                slave="10.20.1.8"
        else
                slave="10.20.1.7"
        fi

        masterconn=`ssh -i /root/.ssh/id_rsa root@$master 'echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep current|cut -d":" -f2|cut -d "," -f1'`
        masteravil=`ssh -i /root/.ssh/id_rsa root@$master 'echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep available|cut -d":" -f3|cut -d "," -f1'`
        mastermaxconn=`echo "$masterconn + $masteravil"|bc`

        slaveconn=`ssh -i /root/.ssh/id_rsa root@$slave 'echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep current|cut -d":" -f2|cut -d "," -f1'`
        slaveavil=`ssh -i /root/.ssh/id_rsa root@$slave 'echo "db.serverStatus().connections"|mongo admin -u admin -p App42MongoRDSDBaaS|grep available|cut -d":" -f3|cut -d "," -f1'`
        slavemaxconn=`echo "$slaveconn + $slaveavil"|bc`

sed -i s/"maxIncomingConnections: $mastermaxconn"/"maxIncomingConnections: $3"/g /etc/mongod.conf

        ssh -i /root/.ssh/id_rsa root@$master 'sed -i s/"maxIncomingConnections: '$slavemaxconn'"/"maxIncomingConnections: '$2'"/g /etc/mongod.conf'
        if [ $? -ne 0 ]; then
                exit 1
        fi
        ssh -i /root/.ssh/id_rsa root@$slave 'sed -i s/"maxIncomingConnections: '$slavemaxconn'"/"maxIncomingConnections: '$2'"/g /etc/mongod.conf'

        if [ $? -eq 0 ]; then
                ssh -i /root/.ssh/id_rsa root@$master /etc/init.d/mongod restart
                ssh -i /root/.ssh/id_rsa root@$slave /etc/init.d/mongod restart
                echo '{"code":5000,"success":"true","message":"MongoDB Max Connection Update Successfully","New Max Connection":"'$2'"}'
        else
                echo '{"success":"false","code":3001, "message":"MongoDB Max Connection Updation Failed"}'
        fi
        ;;

get.slave.status)
        master=`ssh -i /root/.ssh/id_rsa root@10.20.1.7 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        if [ -z $master ]; then
                master=`ssh -i /root/.ssh/id_rsa root@10.20.1.8 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        fi
        if [ 10.20.1.7 == $master ]; then
                slave="10.20.1.8"
        else
                slave="10.20.1.7"
        fi

        behind_the_primary1=`ssh -i /root/.ssh/id_rsa root@$master "echo 'db.printSlaveReplicationInfo()'|mongo admin -u admin -p App42MongoRDSDBaaS|grep 'behind the primary'"`
        behind_the_primary=`echo $behind_the_primary1|awk '{print $1}'`
                if [ ! -z "$behind_the_primary" ]; then
                        echo '{"code":5000,"success":"true","message":"Current MongoDB Slave Status","Seconds Behind Master":"'$behind_the_primary'"}'
                else
                        sleep 1
                        echo '{"success":"false","code":3001, "message":"Current MongoDB Slave Status Could Not Be Fetch, Due To MongoDB Not Running"}'
                fi
        ;;

update.user.password)
        dbname=$2
        username=$3
        newpassword=$4
        master=`ssh -i /root/.ssh/id_rsa root@10.20.1.7 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        if [ -z $master ]; then
                master=`ssh -i /root/.ssh/id_rsa root@10.20.1.8 'mongo admin -u admin -p App42MongoRDSDBaaS --eval "printjson(rs.isMaster())"|grep "primary"|cut -d"\"" -f4|cut -d":" -f1'`
        fi
        if [ 10.20.1.7 == $master ]; then
                slave="10.20.1.8"
        else
                slave="10.20.1.7"
        fi
        ssh -i /root/.ssh/id_rsa root@$master 'echo "db.getSiblingDB('"'$dbname'"').changeUserPassword('"'$username'"','"'$newpassword'"')"|mongo admin -u admin -p App42MongoRDSDBaaS'
        if [ $? -eq 0 ]; then
                echo '{"code":5000,"success":"true","message":"MongoDB Password Update Successfully"}'
        else
                echo '{"success":"false","code":3001, "message":"Current MongoDB Password Could Not Be Update"}'
        fi
        ;;

esac
