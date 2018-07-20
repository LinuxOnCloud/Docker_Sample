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

get.redis.info)
                d=`netstat -npl|grep redis-server|grep 6379|head -1|rev|awk '{print $1}'|cut -d '/' -f2`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        used_cpu=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
                        echo 1 > /proc/sys/vm/drop_caches
                        total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`
                        used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
                        mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
                        dsk=`df  -T|grep "/var/lib/redis"|awk '{print $3}'`
                        disk_MB=`echo "$dsk / 1000 + 50"|bc`
                        load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
                       #conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                       # conn=`echo $conn_stat|grep "Threads_connected"|awk '{print $8}'`
                       conn=`echo "INFO" | redis-cli -a $2 | grep connected_clients|cut -d ':' -f2|tr -d '\r'`
                       #cache=`echo $conn_stat|grep "Threads_cached"|awk '{print $6}'`
                       #max_conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW VARIABLES LIKE "max_connections"' 2> /tmp/err1`
                       #max_conn=`echo $max_conn_stat|grep "max_connections"|awk '{print $4}'`
                        max_conn=`echo "config get maxclients"|redis-cli -a $2|tail -1`
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
                        echo '{"code":5000,"success":"true","message":"Current Redis VM Info", "CPU":"'$used_cpu'", "Memory":"'$mem_percent'", "Load Avg":"'$load'", "Threads Connected":"'$conn'", "Max Connection":"'$max_conn'", "Used Data Disk":"'$disk_MB'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Redis VM Info Could Not Be Fetch, Due To Redis Not Running"}'
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

get.redis.connection)
                d=`netstat -npl|grep redis-server|grep 6379|head -1|rev|awk '{print $1}'|cut -d '/' -f2`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                #       conn_stat=`mysql -u root -pApp42ShepAdmin  -e 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections"' 2> /tmp/err`
                #       conn=`echo $conn_stat|grep "Threads_connected"|awk '{print $8}'`
                        conn=`echo "INFO" | redis-cli -a $2 | grep connected_clients|cut -d ':' -f2|tr -d '\r'`
                        if [ -z "$conn" ]; then
                                err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 53300 -eq $err ]; then
                                        conn="-1"
                                fi
                        fi
                        rm -rf /tmp/err
                        echo '{"code":5000,"success":"true","message":"Current Redis Threads Connected","Threads Connected":"'$conn'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Redis Threads Connected Could Not Be Fetch, Due To Redis Not Running"}'
                fi
        ;;

get.system.load)
        load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
        echo '{"code":5000,"success":"true","message":"Current System Load Average","Load Avg":"'$load'"}'
        ;;


get.redis.max.connection)
                d=`netstat -npl|grep redis-server|grep 6379|head -1|rev|awk '{print $1}'|cut -d '/' -f2`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        max_conn=`echo "config get maxclients"|redis-cli -a $2|tail -1`
                        echo '{"code":5000,"success":"true","message":"Current Max Connection Set on Redis","Max Connection":"'$max_conn'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Max Connection Set on Redis Could Not Be Fetch, Due To Redis Not Running"}'
                fi
        ;;


get.current.master)

        master=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $master == slave ]; then
                master=`echo "INFO" | redis-cli -a $2 | grep master_host|cut -d ':' -f2|tr -d '\r'`
        fi
        if [ $master == master ]; then
                master=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi

        if [ ! -z $master ]; then
                echo '{"code":5000,"success":"true","message":"Current Redis Master","Master":"'$master'"}'
        else
                echo '{"success":"false","code":3001, "message":"We Cannot Find Redis Master"}'


        fi
        ;;


get.current.slave)
        slave=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $slave == slave ]; then
                slave=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi
        if [ $slave == master ]; then
                slave=`echo "INFO" | redis-cli -a $2 | grep slave0|cut -d '=' -f2|cut -d ',' -f1|tr -d '\r'`
        fi
        if [ ! -z $slave ]; then
                echo '{"code":5000,"success":"true","message":"Current Redis Slave","Slave":"'$slave'"}'

                else
                        echo '{"success":"false","code":3001, "message":"We Cannot Find Redis Slave"}'

        fi
        ;;

get.failover.agent.status)
        p1=`ssh -i /root/.ssh/id_rsa root@10.20.1.5 ps ax |grep sentinel|grep -v grep|awk '{print $1}'`
        p2=`ssh -i /root/.ssh/id_rsa root@10.20.1.6 ps ax |grep sentinel|grep -v grep|awk '{print $1}'`
        r1=`ssh -i /root/.ssh/id_rsa root@10.20.1.7 ps ax |grep sentinel|grep -v grep|awk '{print $1}'`
        r2=`ssh -i /root/.ssh/id_rsa root@10.20.1.8 ps ax |grep sentinel|grep -v grep|awk '{print $1}'`

        if [ ! -z $p1 ] && [ ! -z $p2 ] && [ ! -z $r1 ] && [ ! -z $r2 ]; then
                echo '{"code":5000,"success":"true","message":"Sentinel Process Is Running"}'
        else
                echo '{"success":"false","code":3001, "message":"Sentinel Process Is Not Running"}'
        fi
        ;;



run.failover)
        master=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $master == slave ]; then
                master=`echo "INFO" | redis-cli -a $2 | grep master_host|cut -d ':' -f2|tr -d '\r'`
        fi
        if [ $master == master ]; then
                master=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi

        slave=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $slave == slave ]; then
                slave=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi
        if [ $slave == master ]; then
                slave=`echo "INFO" | redis-cli -a $2 | grep slave0|cut -d '=' -f2|cut -d ',' -f1|tr -d '\r'`
        fi

        p1=`ssh -i /root/.ssh/id_rsa root@10.20.1.5 ps ax |grep sentinel|grep -v grep|awk '{print $1}'`
        p2=`ssh -i /root/.ssh/id_rsa root@10.20.1.6 ps ax |grep sentinel|grep -v grep|awk '{print $1}'`
        r1=`ssh -i /root/.ssh/id_rsa root@$master ps ax |grep sentinel|grep -v grep|awk '{print $1}'`
        r2=`ssh -i /root/.ssh/id_rsa root@$slave ps ax |grep sentinel|grep -v grep|awk '{print $1}'`

        if [ -z $p1 ] && [ -z $p2 ] && [ -z $r2 ]; then
                echo '{"success":"false","code":3001, "message":"Not Running Sentinel On Any VM, We Can Not Run Redis Failover"}'
                exit 1
        fi

        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
        ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/redis stop $2
        count=1
        while [ $count -lt 16 ]; do
                new_master=`ssh -i /root/.ssh/id_rsa root@$slave echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
                if [ $new_master == master ]; then
                        count=17
                        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
                        ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
                        echo '{"code":5000,"success":"true","message":"Redis Failover Completed Successfully","New Master":"'$slave'"}'
                        exit 0
                else
                        count=$((count+1))
                        sleep 30
                fi
        done
        ssh -i /root/.ssh/id_rsa root@"$master" sed -i '/check_db/d' /etc/crontab
        ssh -i /root/.ssh/id_rsa root@"$master" 'echo "*/2     *       *       *       *       root    /app42RDS/sbin/check_db" >> /etc/crontab'
        ssh -i /root/.ssh/id_rsa root@"$master" /etc/init.d/redis restart $2
        echo '{"success":"false","code":3001, "message":"Redis Failover Could Not Be Succeed"}'
        ;;

update.max.connection)
        master=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $master == slave ]; then
                master=`echo "INFO" | redis-cli -a $2 | grep master_host|cut -d ':' -f2|tr -d '\r'`
        fi

        if [ $master == master ]; then
                master=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi

        slave=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $slave == slave ]; then
                slave=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi
        if [ $slave == master ]; then
                slave=`echo "INFO" | redis-cli -a $2 | grep slave0|cut -d '=' -f2|cut -d ',' -f1|tr -d '\r'`
        fi

        mastermaxconn=`ssh -i /root/.ssh/id_rsa root@"$master" cat /etc/redis.conf|grep maxclients|awk '{print $2}'`
        slavemaxconn=`ssh -i /root/.ssh/id_rsa root@"$master" cat /etc/redis.conf|grep maxclients|awk '{print $2}'`

        ssh -i /root/.ssh/id_rsa root@$master 'sed -i s/"maxclients '$mastermaxconn'"/"maxclients '$3'"/g /etc/redis.conf'
        ssh -i /root/.ssh/id_rsa root@$slave 'sed -i s/"maxclients '$slavemaxconn'"/"maxclients '$3'"/g /etc/redis.conf'

        if [ $? -eq 0 ]; then
                ssh -i /root/.ssh/id_rsa root@$master /etc/init.d/redis restart $2
                ssh -i /root/.ssh/id_rsa root@$slave /etc/init.d/redis restart $2
                echo '{"code":5000,"success":"true","message":"Redis Max Connection Update Successfully","New Max Connection":"'$3'"}'
        else
                echo '{"success":"false","code":3001, "message":"Redis Max Connection Updation Failed"}'
        fi
        ;;

get.slave.status)
        slave=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $slave == slave ]; then
                slave=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi
        if [ $slave == master ]; then
                slave=`echo "INFO" | redis-cli -a $2 | grep slave0|cut -d '=' -f2|cut -d ',' -f1|tr -d '\r'`
        fi

        master_sync_in_progress=`ssh -i /root/.ssh/id_rsa root@$slave 'echo "INFO" | redis-cli -a '$2' | grep master_sync_in_progress|cut -d ":" -f2|tr -d "\r"'`

                if [ ! -z "$master_sync_in_progress" ]; then
                        echo '{"code":5000,"success":"true","message":"Current Redis Slave Status","Seconds Behind Master":"'$master_sync_in_progress'"}'
                else
                        sleep 1
                        echo '{"success":"false","code":3001, "message":"Current Redis Slave Status Could Not Be Fetch, Due To Redis Not Running"}'
                fi
        ;;

update.user.password)
        oldpassword=$2
        newpassword=$3

        master=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $master == slave ]; then
                master=`echo "INFO" | redis-cli -a $2 | grep master_host|cut -d ':' -f2|tr -d '\r'`
        fi
        if [ $master == master ]; then
                master=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi

        slave=`echo "INFO" | redis-cli -a $2 | grep role|cut -d ':' -f2|tr -d '\r'`
        if [ $slave == slave ]; then
                slave=`ip \r|grep "proto kernel  scope link  src"|rev|awk '{print $1}'|rev`
        fi
        if [ $slave == master ]; then
                slave=`echo "INFO" | redis-cli -a $2 | grep slave0|cut -d '=' -f2|cut -d ',' -f1|tr -d '\r'`
        fi

        ssh -i /root/.ssh/id_rsa root@$master 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/redis.conf'
        ssh -i /root/.ssh/id_rsa root@$slave 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/redis.conf'
        ssh -i /root/.ssh/id_rsa root@$master 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/redis-sentinel.conf'
        ssh -i /root/.ssh/id_rsa root@$slave 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/redis-sentinel.conf'
        ssh -i /root/.ssh/id_rsa root@10.20.1.5 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/redis-sentinel.conf'
        ssh -i /root/.ssh/id_rsa root@10.20.1.6 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/redis-sentinel.conf'
        ssh -i /root/.ssh/id_rsa root@10.20.1.5 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/haproxy/haproxy.cfg'
        ssh -i /root/.ssh/id_rsa root@10.20.1.6 'sed -i s/"'$oldpassword'"/"'$newpassword'"/g /etc/haproxy/haproxy.cfg'

        if [ $? -eq 0 ]; then
                ssh -i /root/.ssh/id_rsa root@$master /etc/init.d/redis-sentinel restart
                ssh -i /root/.ssh/id_rsa root@$slave /etc/init.d/redis-sentinel restart
                ssh -i /root/.ssh/id_rsa root@10.20.1.5 /etc/init.d/redis-sentinel restart
                ssh -i /root/.ssh/id_rsa root@10.20.1.6 /etc/init.d/redis-sentinel restart
                ssh -i /root/.ssh/id_rsa root@$master /etc/init.d/redis restart $2
                ssh -i /root/.ssh/id_rsa root@$slave /etc/init.d/redis restart $2
                ssh -i /root/.ssh/id_rsa root@10.20.1.5 /etc/init.d/haproxy restart
                ssh -i /root/.ssh/id_rsa root@10.20.1.6 /etc/init.d/haproxy restart
                echo '{"code":5000,"success":"true","message":"Redis Password Update Successfully"}'
        else
                echo '{"success":"false","code":3001, "message":"Current Redis Password Could Not Be Update"}'
        fi
        ;;

esac
