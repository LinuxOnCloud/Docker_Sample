#!/bin/bash

case $1 in

configure)

        old_ip=`/bin/cat /etc/opscode/chef-server.rb|head -1|cut -d'"' -f2`
        echo "Old_IP = $old_ip"
        /bin/sed -ie 's/'$old_ip'/'$2'/g' /etc/opscode/chef-server.rb
#        nginz_old=`/bin/cat /var/opt/opscode/nginx/etc/nginx.conf |grep server_name|head -1|awk '{print $2}'`
#        /bin/sed -ie 's/server_name '$nginz_old'/server_name '$2';/g' /var/opt/opscode/nginx/etc/nginx.conf
	/vmpath/sbin/ipchanger $2 &
	/usr/bin/chef-server-ctl reconfigure
	if [ $? -eq 0 ]; then
		kill -9 `ps -x |grep vmpath|grep ipchanger|awk '{print $1}'`
		/usr/bin/opscode-manage-ctl reconfigure
		if [ $? -eq 0 ]; then
			/usr/bin/chef-server-ctl restart
			if [ $? -eq 0 ]; then
				echo '{"code":5000,"success":"true","message":"Chef Server Configured Successfully"}'
			else
				echo '{"success":"false","code":5101,"message":"Chef Server Restarting Failed"}'
			fi
		else
			echo '{"success":"false","code":5102,"message":"Chef Server WebUi Tool Configuration Failed"}'
		fi
	else
		echo '{"success":"false","code":5103,"message":"Chef Server Configuration Failed"}'
	fi;;

adduser)

	/usr/bin/chef-server-ctl user-create $2 a b $6 $3 --filename /home/paasadmin/keys/$2.pem
	if [ $? -eq 0 ]; then
		/usr/bin/chef-server-ctl org-create $4 $5 --association_user $2 --filename /home/paasadmin/keys/$4-validator.pem
		if [ $? -eq 0 ]; then
			chown -R paasadmin.paasadmin /home/paasadmin/keys
			echo '{"code":5000,"success":"true","message":"Chef Server User '$2' And Organizations '$4' Created Successfully","UserPemFilePath":"'/home/paasadmin/keys/$2.pem'","OrganizationsPemFilePath":"'/home/paasadmin/keys/$4-validator.pem'"}'
		else
			echo '{"success":"false","code":5104,"message":"Chef Server Organizations '$4' Creation Failed"}'
		fi
	else
		echo '{"success":"false","code":5105,"message":"Chef Server User '$2' Creation Failed"}'
	fi;;
esac

