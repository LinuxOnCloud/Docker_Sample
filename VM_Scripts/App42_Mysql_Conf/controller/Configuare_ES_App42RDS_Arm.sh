#!/bin/bash


proxy1="$1"
proxy2="$2"
mongodb1="$3"
mongodb2="$4"
user_name="$5"
user_password="$6"
setup_name="$7"
mongodb_conn="$8"



#echo -e "\nDate = `date`\n"
counter=1
while [ $counter -le 10 ]
do
#echo "While loop execute $counter"

proxyha1=`azure vm list|grep $setup_name"-es1"|head -1|awk '{print $6}'`
proxyha2=`azure vm list|grep $setup_name"-es2"|head -1|awk '{print $6}'`
mongodbha1=`azure vm list|grep $setup_name"-es3"|head -1|awk '{print $6}'`
mongodbha2=`azure vm list|grep $setup_name"-es4"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $mongodbha1 ] && [ "running" == $mongodbha2 ]; then
#		echo -e "\nDate = `date`\n"
                echo -e "\nSetup ES Server\n"
		ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config create_lvm $mongodb_conn
		if [ $? -eq 1 ]; then
			exit 1
		fi
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 sudo /app42RDS/sbin/app42RDS_config create_lvm $mongodb_conn
		if [ $? -eq 1 ]; then
                        exit 1
                fi

		ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb1 sudo /app42RDS/sbin/app42RDS_config create_lvm $mongodb_conn
                if [ $? -eq 1 ]; then
                        exit 1
                fi
		ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb2 sudo /app42RDS/sbin/app42RDS_config create_lvm $mongodb_conn
                if [ $? -eq 1 ]; then
                        exit 1
                fi
		
                echo -e "\nCreate User In ES Server\n"
                ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 sudo /app42RDS/sbin/app42RDS_config conf_master $user_name $user_password
		if [ $? -eq 1 ]; then
                        exit 1
                fi
		
                counter=11
        else
                sleep 5m
                counter=$(( $counter + 1 ))
		if [ $counter -gt 10 ]; then
			exit 1
		fi
        fi
done





