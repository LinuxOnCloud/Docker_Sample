#!/bin/bash

if [ "$1" == "qscguk." ]; then

/home/azureuser/Installationpkg/comman/setenv poiuytrewq
#sudo apt-get update
if [ $? -nq 0 ]; then
exit 1
fi
#
#sudo apt-get -y upgrade
#if [ $? -nq 0 ]; then
#exit 1
#fi

#sudo echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | tee /etc/apt/sources.list.d/postgresql.list
#sudo echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' | sudo tee /etc/apt/sources.list.d/pgdg.list
#echo " Sleep 1 postgresqlha1"
#sleep 10
#sudo wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
#sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#echo " Sleep 2 postgresqlha1"
#sleep 10
sudo chmod 777 /etc /etc/yum.repos.d /etc/yum.repos.d/CentOS-Base.repo && sudo cat /home/azureuser/Installationpkg/comman/centos.repo >> /etc/yum.repos.d/CentOS-Base.repo && sudo chmod 755 /etc /etc/yum.repos.d && sudo chmod 644 /etc/yum.repos.d/CentOS-Base.repo && sudo yum clean all
#sudo apt-get update
#echo " Sleep 3 postgresqlha1"
#sleep 10
if [ $? -eq 0 ]; then
sleep 60
sudo yum install -y /home/azureuser/Installationpkg/comman/rpms/core/bash* /home/azureuser/Installationpkg/comman/rpms/utility/fsarchiver* /home/azureuser/Installationpkg/comman/rpms/utility/mutt* /home/azureuser/Installationpkg/comman/rpms/utility/nc* /home/azureuser/Installationpkg/comman/rpms/utility/tokyocabinet* /home/azureuser/Installationpkg/comman/rpms/utility/urlview*
if [ $? -eq 0 ]; then
#sudo apt-get install -y linux-generic linux-headers-generic linux-image-generic

#host=`hostname`
#domain=`sudo cat /etc/resolv.conf |grep search|awk '{print $2}'`

#sudo debconf-set-selections <<< "postfix postfix/mailname string ${host}.${domain}"
#sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

#sudo apt-get install -y --force-yes  wget ca-certificates lvm2
#echo " Sleep 4 postgresqlha1"
#sleep 10

# postfix mutt mailutils
#sudo apt-get install -y --force-yes postgresql-9.6 postgresql-client-9.6 postgresql-9.6-repmgr

	#sudo update-rc.d postgresql enable
	#sudo systemctl enable postgresql
	#sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/pgdg-96-centos.repo && 
#	sudo yum install -y postgresql96 postgresql96-contrib postgresql96-server repmgr96 && sudo cp -arf /home/azureuser/Installationpkg/mysqlha1/app42RDS /.
	sleep 60
	sudo cp -arf /home/azureuser/Installationpkg/postgresql-proxyha1/app42RDS /.
	#sudo chown -R root.root /app42RDS
	if [ $? -eq 0 ]; then
		#sudo ln -s /usr/pgsql-9.6/bin/* /usr/local/bin/
		/home/azureuser/Installationpkg/comman-postgresql/s_Config poiuytrewq
		if [ $? -eq 0 ]; then
			sudo cp -arf /home/azureuser/Installationpkg/comman-postgresql/.ssh /root/.
		        sudo chown -R root.root /root/.ssh && sudo chmod 700 /root/.ssh && sudo chmod 600 /root/.ssh/authorized_keys /root/.ssh/id_rsa && sudo chmod 644 /root/.ssh/id_rsa.pub
			if [ $? -eq 0 ]; then
				echo "PostgreSQL-ProxyHA Configured Successfully"
			else
				echo "PostgreSQL-ProxyHA SSH Key Not Installed"
				exit 1
			fi
		else
			echo "PostgreSQL-ProxyHA Config Configuration Failed"
			exit 1
		fi
	else
		echo "PostgreSQL-ProxyHA Service Could Not Be Installed"
		exit 1
	fi
else
	echo "PostgreSQL-ProxyHA Repo Setup Failed"
	exit 1
fi

else
        echo "PostgreSQL-ProxyHA CentOS Repo Setup Failed"
        exit 1
fi


else
        echo "You are not authourize person, Please leave now."
        exit
fi