#!/bin/bash


proxy1="$1"
proxy2="$2"
mongodb1="$3"
mongodb2="$4"
db_name="$5"
user_name="$6"
user_password="$7"
setup_name="$8"
mongodb_conn="$9"



#echo -e "\nDate = `date`\n"
counter=1
while [ $counter -le 10 ]
do
#echo "While loop execute $counter"

proxyha1=`azure vm list|grep $setup_name"-proxyha1"|head -1|awk '{print $6}'`
proxyha2=`azure vm list|grep $setup_name"-proxyha2"|head -1|awk '{print $6}'`
mongodbha1=`azure vm list|grep $setup_name"-mongodbha1"|head -1|awk '{print $6}'`
mongodbha2=`azure vm list|grep $setup_name"-mongodbha2"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $mongodbha1 ] && [ "running" == $mongodbha2 ]; then
#		echo -e "\nDate = `date`\n"
		ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb1 sudo /app42RDS/sbin/app42RDS_config create_lvm $mongodb_conn
		if [ $? -eq 1 ]; then
			exit 1
		fi
                echo -e "\nSetup MongoDB Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb2 sudo /app42RDS/sbin/app42RDS_config create_lvm $mongodb_conn
		if [ $? -eq 1 ]; then
                        exit 1
                fi
		
		echo -e "\nSetup ProxyHa1 Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config conf_proxy $mongodb_conn
                if [ $? -eq 1 ]; then
                        exit 1
                fi
		
                echo -e "\nConfiguring MongoDB Master Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb1 sudo /app42RDS/sbin/app42RDS_config conf_master $db_name $user_name $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
		
		echo -e "\nSetup ProxyHa2 Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 sudo /app42RDS/sbin/app42RDS_config conf_proxy
                if [ $? -eq 1 ]; then
                        exit 1
                fi


		echo -e "\nConfiguring MongoDB Auth Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb1 sudo /app42RDS/sbin/app42RDS_config add_auth
		if [ $? -eq 1 ]; then
                        exit 1
                fi

                echo -e "\nConfiguring MongoDB Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb2 sudo /app42RDS/sbin/app42RDS_config conf_slave
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nConfiguring ProxyHa1 Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config conf_slave
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





