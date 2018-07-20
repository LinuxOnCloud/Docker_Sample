#!/bin/bash


proxy1="$1"
proxy2="$2"
redis1="$3"
redis2="$4"
redis_conn="$5"
setup_name="$6"
#postgresql_version="$7"

echo -e "\nPlease Wait VM's are Starting"
#echo -e "\nDate = `date`\n"

counter=1
while [ $counter -le 10 ]
do
echo -e "\nWhile loop execute $counter"

proxyha1=`azure vm list|grep $setup_name"-proxyha1"|head -1|awk '{print $6}'`
proxyha2=`azure vm list|grep $setup_name"-proxyha2"|head -1|awk '{print $6}'`
redisha1=`azure vm list|grep $setup_name"-redisha1"|head -1|awk '{print $6}'`
redisha2=`azure vm list|grep $setup_name"-redisha2"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $redisha1 ] && [ "running" == $redisha2 ]; then
#	echo -e "\nDate = `date`\n"
	echo -e "\nApp42 PostgresqlHA Solution Installing\n"

parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis1 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis2 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'"
if [ $? -eq 0 ]; then
	parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis1 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis2 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'"
        if [ $? -eq 0 ]; then
                parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis1 'sudo /home/azureuser/Installationpkg/redisha1/settingup qscguk. $redis_conn'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis2 'sudo /home/azureuser/Installationpkg/redisha2/settingup qscguk. $redis_conn'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 'sudo /home/azureuser/Installationpkg/redisproxyha1/settingup qscguk.'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 'sudo /home/azureuser/Installationpkg/redisproxyha2/settingup qscguk.'"
                #parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis1 'sudo /home/azureuser/Installationpkg/redisha1/settingup qscguk. $redis_conn $postgresql_version'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$redis2 'sudo /home/azureuser/Installationpkg/redisha2/settingup qscguk. $redis_conn $postgresql_version'"
		if [ $? -eq 0 ]; then
#			echo -e "\nDate = `date`\n"
			counter=11
			echo "Packeges Installed Successfully"
		else
			exit 1
		fi
	else
		exit 1
	fi
else
	exit 1
fi

else
                sleep 5m
                counter=$(( $counter + 1 ))
                if [ $counter -gt 10 ]; then
                        exit 1
                fi
        fi
done
