db_name="$1"
user_name="$2"
setup_name="$3"
user_password="$4"



counter=1
while [ $counter -le 10 ]
do
#echo "While loop execute $counter"

proxyha1=`azure vm list|grep $setup_name'-proxyha1'|head -1|awk '{print $3}'`
proxyha2=`azure vm list|grep $setup_name'-proxyha2'|head -1|awk '{print $3}'`
mysqlha1=`azure vm list|grep $setup_name'-mysqlha1'|head -1|awk '{print $3}'`
mysqlha2=`azure vm list|grep $setup_name'-mysqlha2'|head -1|awk '{print $3}'`

        if [ "ReadyRole" == $proxyha1 ] && [ "ReadyRole" == $proxyha2 ] && [ "ReadyRole" == $mysqlha1 ] && [ "ReadyRole" == $mysqlha2 ]; then
		echo -e "\nSetup MySQL Master Server\n"
		ssh -i /app42RDS/sbin/app42rds_key -p 22 -t azureuser@$setup_name-mysqlha.cloudapp.net sudo /app42RDS/sbin/app42RDS_config.sh create_lvm
		echo -e "\nSetup MySQL Slave Server\n"
		ssh -i /app42RDS/sbin/app42rds_key -p 222 -t azureuser@$setup_name-mysqlha.cloudapp.net sudo /app42RDS/sbin/app42RDS_config.sh create_lvm
		echo -e "\nConfiguring MySQL Master Server\n"
		ssh -i /app42RDS/sbin/app42rds_key -p 22 -t azureuser@$setup_name-mysqlha.cloudapp.net sudo /app42RDS/sbin/app42RDS_config.sh conf_master_mysql $db_name $user_name $user_password 
		echo -e "\nConfiguring MySQL Slave Server\n"
		ssh -i /app42RDS/sbin/app42rds_key -p 222 -t azureuser@$setup_name-mysqlha.cloudapp.net sudo /app42RDS/sbin/app42RDS_config.sh conf_slave_mysql
		echo -e "\nSetup ProxyHa1 Server\n"
		ssh -i /app42RDS/sbin/app42rds_key -p 22 -t azureuser@$setup_name-proxyha.cloudapp.net sudo /app42RDS/sbin/app42RDS_config.sh conf_mha $setup_name
		echo -e "\nSetup ProxyHa2 Server\n"
		ssh -i /app42RDS/sbin/app42rds_key -p 222 -t azureuser@$setup_name-proxyha.cloudapp.net sudo /app42RDS/sbin/app42RDS_config.sh conf_mha $setup_name
		echo -e "\nStarting ProxyHa1 Server\n"
		ssh -i /app42RDS/sbin/app42rds_key -p 22 -t azureuser@$setup_name-proxyha.cloudapp.net sudo /app42RDS/sbin/app42RDS_config.sh start_mha
                counter=11
        else
                sleep 5m
                counter=$(( $counter + 1 ))
		if [ $counter -gt 10 ]; then
			exit 1
		fi
        fi
done





