#!/bin/bash

if [ "$1" == "qscguk." ]; then

/home/azureuser/Installationpkg/comman/setenv poiuytrewq
if [ $? -nq 0 ]; then
exit 1
fi

sudo chmod 777 /etc /etc/yum.repos.d /etc/yum.repos.d/CentOS-Base.repo && sudo cat /home/azureuser/Installationpkg/comman/centos.repo >> /etc/yum.repos.d/CentOS-Base.repo && sudo chmod 755 /etc /etc/yum.repos.d && sudo chmod 644 /etc/yum.repos.d/CentOS-Base.repo && sudo yum clean all
if [ $? -eq 0 ]; then

sudo yum install -y /home/azureuser/Installationpkg/comman/rpms/core/bash* /home/azureuser/Installationpkg/comman/rpms/utility/mha4mysql* /home/azureuser/Installationpkg/comman/rpms/utility/perl* /home/azureuser/Installationpkg/comman/rpms/utility/mailx* /home/azureuser/Installationpkg/comman/rpms/utility/mutt* /home/azureuser/Installationpkg/comman/rpms/utility/nc* /home/azureuser/Installationpkg/comman/rpms/utility/tokyocabinet* /home/azureuser/Installationpkg/comman/rpms/utility/urlview*

if [ $? -eq 0 ]; then
	sudo cp -arf /home/azureuser/Installationpkg/proxyha1/app42RDS /.
	sudo chown -R root.root /app42RDS
	if [ $? -eq 0 ]; then
		/home/azureuser/Installationpkg/comman/failover poiuytrewq
		/home/azureuser/Installationpkg/comman/failover_recovery poiuytrewq
		sudo cp -arf /home/azureuser/Installationpkg/comman/mha /etc/.
		sudo chown -R root.root /etc/mha
		if [ $? -eq 0 ]; then
			/home/azureuser/Installationpkg/comman/s_Config poiuytrewq
			sudo cp -arf /home/azureuser/Installationpkg/comman/.ssh /root/.
			sudo chown -R root.root /root/.ssh && sudo chmod 700 /root/.ssh && sudo chmod 600 /root/.ssh/authorized_keys /root/.ssh/id_rsa && sudo chmod 644 /root/.ssh/id_rsa.pub
			if [ $? -eq 0 ]; then
				echo "ProxyHA1 Configured Successfully"
			else
				echo "SSH Key Not Installed"
				exit 1
			fi
		else
			echo "MHA Configuration Failed"
			exit 1
		fi
	else
		echo "Configuration Script Insatllation Failed"
		exit 1
	fi
else
	echo "MHA PKG Installation Failed"
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
