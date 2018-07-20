#!/bin/bash

if [ "$1" == "qscguk." ]; then

/home/azureuser/Installationpkg/comman/setenv poiuytrewq
if [ $? -nq 0 ]; then
exit 1
fi

sudo chmod 777 /etc /etc/yum.repos.d /etc/yum.repos.d/CentOS-Base.repo && sudo cat /home/azureuser/Installationpkg/comman/centos.repo >> /etc/yum.repos.d/CentOS-Base.repo && sudo chmod 755 /etc /etc/yum.repos.d && sudo chmod 644 /etc/yum.repos.d/CentOS-Base.repo && sudo yum clean all
if [ $? -eq 0 ]; then

sudo yum install -y /home/azureuser/Installationpkg/comman/rpms/core/bash* /home/azureuser/Installationpkg/comman/rpms/utility/mha4mysql* /home/azureuser/Installationpkg/comman/rpms/utility/perl* /home/azureuser/Installationpkg/comman/rpms/utility/fsarchiver* /home/azureuser/Installationpkg/comman/rpms/utility/mysql-community-release*

if [ $? -eq 0 ]; then
	sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/mysql-community.repo && sudo yum install -y mysql-community-server-$3 mysql-community-client-$3 mysql-community-common-$3 mysql-community-libs-compat-$3 mysql-community-libs-$3 && sudo cp -arf /home/azureuser/Installationpkg/mysqlha1/app42RDS /.
	sudo chown -R root.root /app42RDS
	if [ $? -eq 0 ]; then
		/home/azureuser/Installationpkg/comman/master_config poiuytrewq $2
		sudo cp -arf /home/azureuser/Installationpkg/comman/master.cnf /etc/my.cnf
		sudo chown -R root.root /etc/my.cnf
		if [ $? -eq 0 ]; then
			/home/azureuser/Installationpkg/comman/s_Config poiuytrewq
			sudo cp -arf /home/azureuser/Installationpkg/comman/.ssh /root/.
			sudo chown -R root.root /root/.ssh && sudo chmod 700 /root/.ssh && sudo chmod 600 /root/.ssh/authorized_keys /root/.ssh/id_rsa && sudo chmod 644 /root/.ssh/id_rsa.pub
			if [ $? -eq 0 ]; then
				echo "MysqlHA1 Configured Successfully"
			else
				echo "SSH Key Not Installed"
				exit 1
			fi
		else
			echo "MySQL Config  Configuration Failed"
			exit 1
		fi
	else
		echo "MySQL Insatllation Failed"
		exit 1
	fi
else
	echo "MHA Node & MySQL Community PKG Installation Failed"
	exit 1
fi

else 

	echo "Repo Mirror not set MHA Node"
        exit 1
fi

else
        echo "You are not authourize person, Please leave now."
        exit
fi
