#!/bin/bash


proxy1="$1"
proxy2="$2"
redis1="$3"
redis2="$4"
redis_mem="$5"
redis_conn="$6"
user_password="$7"
setup_name="$8"



#echo -e "\nDate = `date`\n"
counter=1
while [ $counter -le 10 ]
do
#echo "While loop execute $counter"

proxyha1=`azure vm list|grep $setup_name"-proxyha1"|head -1|awk '{print $6}'`
proxyha2=`azure vm list|grep $setup_name"-proxyha2"|head -1|awk '{print $6}'`
redisha1=`azure vm list|grep $setup_name"-redisha1"|head -1|awk '{print $6}'`
redisha2=`azure vm list|grep $setup_name"-redisha2"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $redisha1 ] && [ "running" == $redisha2 ]; then
#		echo -e "\nDate = `date`\n"
		ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis1 sudo /app42RDS/sbin/app42RDS_config create_lvm $redis_conn $redis_mem
		if [ $? -eq 1 ]; then
			exit 1
		fi
                echo -e "\nSetup Redis Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis2 sudo /app42RDS/sbin/app42RDS_config create_lvm $redis_conn $redis_mem
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nConfiguring Redis Master Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis1 sudo /app42RDS/sbin/app42RDS_config conf_master $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nConfiguring Redis Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis2 sudo /app42RDS/sbin/app42RDS_config conf_slave $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nSetup ProxyHa1 Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config conf_proxy $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nSetup ProxyHa2 Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 sudo /app42RDS/sbin/app42RDS_config conf_proxy $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                #echo -e "\nStarting ProxyHa1 Server\n"
                #ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config start_mha
		#if [ $? -eq 1 ]; then
                #        exit 1
                #fi
                #ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config set_cron
		#if [ $? -eq 1 ]; then
                #        exit 1
                #fi
                #ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 sudo /app42RDS/sbin/app42RDS_config set_cron
		#if [ $? -eq 1 ]; then
                #        exit 1
                #fi
                counter=11
#		echo -e "\nDate = `date`\n"
        else
                sleep 5m
                counter=$(( $counter + 1 ))
		if [ $counter -gt 10 ]; then
			exit 1
		fi
        fi
done





