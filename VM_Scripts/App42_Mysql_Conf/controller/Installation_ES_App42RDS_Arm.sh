#!/bin/bash


proxy1="$1"
proxy2="$2"
mongodb1="$3"
mongodb2="$4"
mongodb_conn="$5"
setup_name="$6"


echo -e "\nPlease Wait VM's are Starting"
#echo -e "\nDate = `date`\n"

counter=1
while [ $counter -le 10 ]
do
echo -e "\nWhile loop execute $counter"

proxyha1=`azure vm list|grep $setup_name"-es1"|head -1|awk '{print $6}'`
proxyha2=`azure vm list|grep $setup_name"-es2"|head -1|awk '{print $6}'`
mongodbha1=`azure vm list|grep $setup_name"-es3"|head -1|awk '{print $6}'`
mongodbha2=`azure vm list|grep $setup_name"-es4"|head -1|awk '{print $6}'`

        if [ "running" == $proxyha1 ] && [ "running" == $proxyha2 ] && [ "running" == $mongodbha1 ] && [ "running" == $mongodbha2 ]; then
	echo -e "\nApp42 ES Solution Installing\n"

parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb1 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb2 'wget https://s3-ap-southeast-1.amazonaws.com/app42packege/git2.tgz && tar xzf git2.tgz'"
if [ $? -eq 0 ]; then
	parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb1 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb2 '/home/azureuser/git/bin/git clone https://github.com/abc/Installationpkg.git'"
        if [ $? -eq 0 ]; then
                parallelshell "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb1 'sudo /home/azureuser/Installationpkg/es3/settingup qscguk. $mongodb_conn'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mongodb2 'sudo /home/azureuser/Installationpkg/es4/settingup qscguk. $mongodb_conn'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy1 'sudo /home/azureuser/Installationpkg/es1/settingup qscguk.'" "ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$proxy2 'sudo /home/azureuser/Installationpkg/es2/settingup qscguk.'"
		if [ $? -eq 0 ]; then
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
