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

get.es.info)
                d=`netstat -npl|grep java|grep 9200|head -1|rev|awk '{print $1}'|cut -d '/' -f2`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        used_cpu=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
                        echo 1 > /proc/sys/vm/drop_caches
                        total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`
                        used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
                        mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
                        dsk=`df  -T|grep "/var/lib/elasticsearch"|awk '{print $3}'`
                        disk_MB=`echo "$dsk / 1000 + 50"|bc`
                        load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`

                        nodekey=`curl -u elastic:App42ElasticRDS http://localhost:9200/_nodes/thread_pool\?pretty|/app42RDS/sbin/jq-linux64 '.nodes | keys[]'|head -1`

                        esconn=`curl -u elastic:App42ElasticRDS http://localhost:9200/_nodes/thread_pool\?pretty|/app42RDS/sbin/jq-linux64 '.nodes.'$nodekey'.thread_pool.index.queue_size'`
                        max_conn=`echo "$esconn * 4"|bc`
                        es1=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es1"|grep bulk|awk '{print $3}'`
                        es2=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es2"|grep bulk|awk '{print $3}'`
                        es3=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es3"|grep bulk|awk '{print $3}'`
                        es4=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es4"|grep bulk|awk '{print $3}'`
                        conn=`echo "$es1 + $es4 + $es3 + $es4"|bc`
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
                        echo '{"code":5000,"success":"true","message":"Current Elasticsearch VM Info", "CPU":"'$used_cpu'", "Memory":"'$mem_percent'", "Load Avg":"'$load'", "Threads Connected":"'$conn'", "Max Connection":"'$max_conn'", "Used Data Disk":"'$disk_MB'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Elasticsearch VM Info Could Not Be Fetch, Due To Elasticsearch Not Running"}'
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

get.es.connection)
                d=`netstat -npl|grep java|grep 9200|head -1|rev|awk '{print $1}'|cut -d '/' -f2`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        es1=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es1"|grep bulk|awk '{print $3}'`
                        es2=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es2"|grep bulk|awk '{print $3}'`
                        es3=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es3"|grep bulk|awk '{print $3}'`
                        es4=`curl -XGET -u elastic:App42ElasticRDS 'localhost:9200/_cat/thread_pool?pretty'|grep "es4"|grep bulk|awk '{print $3}'`
                        conn=`echo "$es1 + $es4 + $es3 + $es4"|bc`
                        if [ -z "$conn" ]; then
                                err=`cat /tmp/err |grep "ERROR"|awk '{print $2}'`
                                if [ 53300 -eq $err ]; then
                                        conn="-1"
                                fi
                        fi
                        rm -rf /tmp/err
                        echo '{"code":5000,"success":"true","message":"Current Elasticsearch Threads Connected","Threads Connected":"'$conn'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Elasticsearch Threads Connected Could Not Be Fetch, Due To Elasticsearch Not Running"}'
                fi
        ;;

get.system.load)
        load=`uptime |rev|cut -d ',' -f3|rev|cut -d ':' -f2|tr -d ' '`
        echo '{"code":5000,"success":"true","message":"Current System Load Average","Load Avg":"'$load'"}'
        ;;


get.es.max.connection)
                d=`netstat -npl|grep java|grep 9200|head -1|rev|awk '{print $1}'|cut -d '/' -f2`
                /bin/echo "d=$d"
                if [ ! -z $d ]; then
                        nodekey=`curl -u elastic:App42ElasticRDS http://localhost:9200/_nodes/thread_pool\?pretty|/app42RDS/sbin/jq-linux64 '.nodes | keys[]'|head -1`

                        esconn=`curl -u elastic:App42ElasticRDS http://localhost:9200/_nodes/thread_pool\?pretty|/app42RDS/sbin/jq-linux64 '.nodes.'$nodekey'.thread_pool.index.queue_size'`
                        max_conn=`echo "$esconn * 4"|bc`
                        echo '{"code":5000,"success":"true","message":"Current Max Connection Set on Elasticsearch","Max Connection":"'$max_conn'"}'
                else
                        echo '{"success":"false","code":3001, "message":"Current Max Connection Set on Elasticsearch Could Not Be Fetch, Due To Elasticsearch Not Running"}'
                fi
        ;;


update.max.connection)
sed -i s/'queue_size: 500'/'queue_size: 2500'/g /etc/elasticsearch/elasticsearch.yml

        nodekey=`curl -u elastic:App42ElasticRDS http://localhost:9200/_nodes/thread_pool\?pretty|/app42RDS/sbin/jq-linux64 '.nodes | keys[]'|head -1`

        esconn=`curl -u elastic:App42ElasticRDS http://localhost:9200/_nodes/thread_pool\?pretty|/app42RDS/sbin/jq-linux64 '.nodes.'$nodekey'.thread_pool.index.queue_size'`
        sed -i s/'queue_size: '$esconn''/'queue_size: '$2''/g /etc/elasticsearch/elasticsearch.yml


        ssh -i /root/.ssh/id_rsa root@10.20.1.6 'sed -i s/"queue_size: '$esconn'"/"queue_size: '$2'"/g /etc/elasticsearch/elasticsearch.yml'
        ssh -i /root/.ssh/id_rsa root@10.20.1.7 'sed -i s/"queue_size: '$esconn'"/"queue_size: '$2'"/g /etc/elasticsearch/elasticsearch.yml'
        ssh -i /root/.ssh/id_rsa root@10.20.1.5 'sed -i s/"queue_size: '$esconn'"/"queue_size: '$2'"/g /etc/elasticsearch/elasticsearch.yml'

        if [ $? -eq 0 ]; then
                /etc/init.d/elasticsearch restart
                sleep 30
                ssh -i /root/.ssh/id_rsa root@10.20.1.6 /etc/init.d/elasticsearch restart
                sleep 30
                ssh -i /root/.ssh/id_rsa root@10.20.1.7 /etc/init.d/elasticsearch restart
                sleep 30
                ssh -i /root/.ssh/id_rsa root@10.20.1.5 /etc/init.d/elasticsearch restart
                echo '{"code":5000,"success":"true","message":"Elasticsearch Max Connection Update Successfully","New Max Connection":"'$3'"}'
        else
                echo '{"success":"false","code":3001, "message":"Elasticsearch Max Connection Updation Failed"}'
        fi
        ;;

update.user.password)
        username=$2
        newpassword=$3

        curl -XPOST -u elastic:App42ElasticRDS 'localhost:9200/_xpack/security/user/'$username'/_password' -H "Content-Type: application/json" -d '{ "password" : "'$newpassword'" }'

        if [ $? -eq 0 ]; then
                echo '{"code":5000,"success":"true","message":"Elasticsearch Password Update Successfully"}'
        else
                echo '{"success":"false","code":3001, "message":"Current Elasticsearch Password Could Not Be Update"}'
        fi
        ;;

esac
