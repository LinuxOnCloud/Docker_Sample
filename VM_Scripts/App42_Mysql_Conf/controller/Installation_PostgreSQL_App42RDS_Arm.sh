#!/bin/bash


proxy1="$1"
proxy2="$2"
postgresql1="$3"
postgresql2="$4"
postgresql_conn="$5"
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
postgresqlha1=`azure vm list|grep $setup_name"-postgresqlha1"|head -1|awk '{print $6}'`
postgresqlha2=`azure vm list|grep $setup_name"-postgresqlha2"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $postgresqlha1 ] && [ "running" == $postgresqlha2 ]; then
#	echo -e "\nDate = `date`\n"
	echo -e "\nApp42 PostgresqlHA Solution Installing\n"

parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql1 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql2 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'"
if [ $? -eq 0 ]; then
	parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql1 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql2 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'"
        if [ $? -eq 0 ]; then
                parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql1 'sudo /home/azureuser/Installationpkg/postgresqlha1/settingup qscguk. $postgresql_conn'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql2 'sudo /home/azureuser/Installationpkg/postgresqlha2/settingup qscguk. $postgresql_conn'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 'sudo /home/azureuser/Installationpkg/postgresql-proxyha1/settingup qscguk.'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 'sudo /home/azureuser/Installationpkg/postgresql-proxyha1/settingup qscguk.'"
                #parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql1 'sudo /home/azureuser/Installationpkg/postgresqlha1/settingup qscguk. $postgresql_conn $postgresql_version'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$postgresql2 'sudo /home/azureuser/Installationpkg/postgresqlha2/settingup qscguk. $postgresql_conn $postgresql_version'"
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
