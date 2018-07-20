#!/bin/bash

proxy1="$1"
proxy2="$2"
mysql1="$3"
mysql2="$4"
db_name="$5"
user_name="$6"
user_password="$7"
setup_name="$8"



#echo -e "\nDate = `date`\n"
counter=1
while [ $counter -le 10 ]
do
#echo "While loop execute $counter"

proxyha1=`azure vm list|grep $setup_name"-proxyha1"|head -1|awk '{print $6}'`
proxyha2=`azure vm list|grep $setup_name"-proxyha2"|head -1|awk '{print $6}'`
mysqlha1=`azure vm list|grep $setup_name"-mysqlha1"|head -1|awk '{print $6}'`
mysqlha2=`azure vm list|grep $setup_name"-mysqlha2"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $mysqlha1 ] && [ "running" == $mysqlha2 ]; then
#		echo -e "\nDate = `date`\n"
		ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mysql1 sudo /app42RDS/sbin/app42RDS_config create_lvm
		if [ $? -eq 1 ]; then
			exit 1
		fi
                echo -e "\nSetup MySQL Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mysql2 sudo /app42RDS/sbin/app42RDS_config create_lvm
		if [ $? -eq 1 ]; then
                        exit 1
                fi
                echo -e "\nConfiguring MySQL Master Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mysql1 sudo /app42RDS/sbin/app42RDS_config conf_master $db_name $user_name $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
		pos=`ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mysql1 cat /tmp/master_position|grep Position|awk '{print $2}'`
                echo -e "\nConfiguring MySQL Slave Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mysql2 sudo /app42RDS/sbin/app42RDS_config conf_slave $pos
		if [ $? -eq 1 ]; then
                        exit 1
                fi
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





