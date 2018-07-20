#!/bin/bash

if [ "$1" == "qscguk." ]; then

#/home/azureuser/Installationpkg/comman/setenv poiuytrewq
#sudo apt-get update
#if [ $? -nq 0 ]; then
#exit 1
#fi

#sudo apt-get -y upgrade
#if [ $? -nq 0 ]; then
#exit 1
#fi

#sudo echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | tee /etc/apt/sources.list.d/postgresql.list
sudo echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' | sudo tee /etc/apt/sources.list.d/pgdg.list
echo " Sleep 1 postgresqlha2"
sleep 10

#sudo wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo " Sleep 2 postgresqlha2"
sleep 10

#sudo chmod 777 /etc /etc/yum.repos.d /etc/yum.repos.d/CentOS-Base.repo && sudo cat /home/azureuser/Installationpkg/comman/centos.repo >> /etc/yum.repos.d/CentOS-Base.repo && sudo chmod 755 /etc /etc/yum.repos.d && sudo chmod 644 /etc/yum.repos.d/CentOS-Base.repo && sudo yum clean all
sudo apt-get update
echo " Sleep 3 postgresqlha1"
sleep 10

#sudo yum install -y /home/azureuser/Installationpkg/comman/rpms/core/bash* /home/azureuser/Installationpkg/comman/rpms/utility/mha4mysql* /home/azureuser/Installationpkg/comman/rpms/utility/perl* /home/azureuser/Installationpkg/comman/rpms/utility/fsarchiver* /home/azureuser/Installationpkg/comman/rpms/utility/mysql-community-release*
#sudo apt-get install -y linux-generic linux-headers-generic linux-image-generic

host=`hostname`
domain=`sudo cat /etc/resolv.conf |grep search|awk '{print $2}'`

#sudo debconf-set-selections <<< "postfix postfix/mailname string ${host}.${domain}"
#sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

sudo apt-get install -y --force-yes wget ca-certificates lvm2 
echo " Sleep 4 postgresqlha1"
sleep 10
#postfix mutt mailutils
sudo apt-get install -y --force-yes postgresql-9.6 postgresql-client-9.6 postgresql-9.6-repmgr

if [ $? -eq 0 ]; then
	sudo update-rc.d postgresql enable
	#sudo systemctl enable postgresql
	#sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/mysql-community.repo && sudo yum install -y mysql-community-server-$3 mysql-community-client-$3 mysql-community-common-$3 mysql-community-libs-compat-$3 mysql-community-libs-$3 && sudo cp -arf /home/azureuser/Installationpkg/mysqlha1/app42RDS /.
	#sudo chown -R root.root /app42RDS
	if [ $? -eq 0 ]; then
		total_mem=`free -m|head -2|tail -1|awk '{print $2}'`
		shared_buffers=`echo "$total_mem * 40 / 100"|bc`
		$HOME/Installationpkg/comman-postgresql/master_config poiuytrewq $2
	#	sudo cp -arf $HOME/Installationpkg/comman-postgresql/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#wal_level = minimal"/"wal_level = hot_standby"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#archive_mode = off"/"archive_mode = on"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#archive_command = ''"/"archive_command = 'cd .'"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#max_wal_senders = 0"/"max_wal_senders = 10"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#wal_keep_segments = 0"/"wal_keep_segments = 10"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#max_replication_slots = 0"/"max_replication_slots = 1"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#hot_standby = off"/"hot_standby = on"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#shared_preload_libraries = ''"/"shared_preload_libraries = 'repmgr_funcs'"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#logging_collector = off"/"logging_collector = on"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#log_directory = 'pg_log'"/"log_directory = '\/var\/lib\/postgresql\/logs\/'"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'"/"log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"#log_file_mode = 0600"/"log_file_mode = 0600"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"max_connections = 100"/"max_connections = $2"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo sed -i s/"shared_buffers = 128MB"/"shared_buffers = ${shared_buffers}MB"/g /etc/postgresql/9.6/main/postgresql.conf
		sudo cp -arf $HOME/Installationpkg/comman-postgresql/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf
		sudo mkdir -p /etc/repmgr
		sudo cp -arf $HOME/Installationpkg/comman-postgresql/repmgr-standby.conf /etc/repmgr/repmgr.conf
		sudo chown -R postgres.postgres /etc/postgresql/9.6/main
		sudo chown -R postgres.postgres /etc/repmgr
		if [ $? -eq 0 ]; then
			sudo cp -arf /home/azureuser/Installationpkg/postgresqlha2/app42RDS /.
			sudo mkdir -p /var/lib/postgresql/logs
			sudo chown -R postgres.postgres /var/lib/postgresql/logs
			$HOME/Installationpkg/comman-postgresql/s_Config poiuytrewq
			sudo cp -arf $HOME/Installationpkg/comman-postgresql/.ssh /root/.
			sudo cp -arf $HOME/Installationpkg/comman-postgresql/.ssh /var/lib/postgresql/.
			sudo chown -R root.root /root/.ssh && sudo chmod 700 /root/.ssh && sudo chmod 600 /root/.ssh/authorized_keys /root/.ssh/id_rsa && sudo chmod 644 /root/.ssh/id_rsa.pub
			sudo chown -R postgres.postgres /var/lib/postgresql/.ssh && sudo chmod 700 /var/lib/postgresql/.ssh && sudo chmod 600 /var/lib/postgresql/.ssh/authorized_keys /var/lib/postgresql/.ssh/id_rsa && sudo chmod 644 /var/lib/postgresql/.ssh/id_rsa.pub
			if [ $? -eq 0 ]; then
				echo "PostgreSQLHA1 Configured Successfully"
			else
				echo "SSH Key Not Installed"
				exit 1
			fi
		else
			echo "PostgreSQLHA1 Config Configuration Failed"
			exit 1
		fi
	else
		echo "PostgreSQLHA1 Service Could Not Be Enabled"
		exit 1
	fi
else
	echo "PostgreSQLHA1 Installation Failed"
	exit 1
fi

else
        echo "You are not authourize person, Please leave now."
        exit
fi
