#!/bin/bash


proxy1="$1"
proxy2="$2"
postgresql1="$3"
postgresql2="$4"
db_name="$5"
user_name="$6"
user_password="$7"
setup_name="$8"
postgresql_conn="$9"



#echo -e "\nDate = `date`\n"
counter=1
while [ $counter -le 10 ]
do
#echo "While loop execute $counter"

proxyha1=`azure vm list|grep $setup_name"-proxyha1"|head -1|awk '{print $6}'`
proxyha2=`azure vm list|grep $setup_name"-proxyha2"|head -1|awk '{print $6}'`
postgresqlha1=`azure vm list|grep $setup_name"-postgresqlha1"|head -1|awk '{print $6}'`
postgresqlha2=`azure vm list|grep $setup_name"-postgresqlha2"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $postgresqlha1 ] && [ "running" == $postgresqlha2 ]; then
#		echo -e "\nDate = `date`\n"
		ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql1 sudo /app42RDS/sbin/app42RDS_config create_lvm $postgresql_conn
		if [ $? -eq 1 ]; then
			exit 1
		fi
                echo -e "\nSetup PostgreSQL Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql2 sudo /app42RDS/sbin/app42RDS_config create_lvm $postgresql_conn
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nConfiguring PostgreSQL Master Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql1 sudo /app42RDS/sbin/app42RDS_config conf_master $db_name $user_name $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nConfiguring PostgreSQL Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql2 sudo /app42RDS/sbin/app42RDS_config conf_slave
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nSetup ProxyHa1 Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config conf_proxy
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nSetup ProxyHa2 Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 sudo /app42RDS/sbin/app42RDS_config conf_proxy
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





