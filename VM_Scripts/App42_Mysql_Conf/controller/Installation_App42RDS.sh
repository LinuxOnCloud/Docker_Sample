#!/bin/bash

db_name="$1"
user_name="$2"
setup_name="$3"
user_password="$4"
proxy="$5"


echo -e "\nPlease Wait VM's are Starting"
#echo -e "\nDate = `date`\n"

counter=1
while [ $counter -le 10 ]
do
echo -e "\nWhile loop execute $counter"

proxyha1=`azure vm list|grep $setup_name'-proxyha1'|head -1|awk '{print $3}'`
proxyha2=`azure vm list|grep $setup_name'-proxyha2'|head -1|awk '{print $3}'`
mysqlha1=`azure vm list|grep $setup_name'-mysqlha1'|head -1|awk '{print $3}'`
mysqlha2=`azure vm list|grep $setup_name'-mysqlha2'|head -1|awk '{print $3}'`

        if [ "ReadyRole" == $proxyha1 ] && [ "ReadyRole" == $proxyha2 ] && [ "ReadyRole" == $mysqlha1 ] && [ "ReadyRole" == $mysqlha2 ]; then
#	echo -e "\nDate = `date`\n"
	echo -e "\nApp42 MysqlHA Solution Installing\n"

parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$setup_name-$proxy.cloudapp.net 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 222 -tt azureuser@$setup_name-$proxy.cloudapp.net 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$setup_name-mysqlha.cloudapp.net 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 222 -tt azureuser@$setup_name-mysqlha.cloudapp.net 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'"
if [ $? -eq 0 ]; then
	parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$setup_name-$proxy.cloudapp.net '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 222 -tt azureuser@$setup_name-$proxy.cloudapp.net '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$setup_name-mysqlha.cloudapp.net '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 222 -tt azureuser@$setup_name-mysqlha.cloudapp.net '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'"
	if [ $? -eq 0 ]; then
		parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$setup_name-$proxy.cloudapp.net 'sudo /home/azureuser/Installationpkg/proxyha1/settingup qscguk.'" "ssh -i /var/keys/app42rds_key -p 222 -tt azureuser@$setup_name-$proxy.cloudapp.net 'sudo /home/azureuser/Installationpkg/proxyha2/settingup qscguk.'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$setup_name-mysqlha.cloudapp.net 'sudo /home/azureuser/Installationpkg/mysqlha1/settingup qscguk.'" "ssh -i /var/keys/app42rds_key -p 222 -tt azureuser@$setup_name-mysqlha.cloudapp.net 'sudo /home/azureuser/Installationpkg/mysqlha2/settingup qscguk.'"
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
