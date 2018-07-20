#!/bin/bash

#start tomcat function
chefstart() {
        sudo /usr/bin/chef-server-ctl start
}

# stop tomcat function
chefstop() {
        sudo /usr/bin/chef-server-ctl stop
}


case $1 in

cmd)
                 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}          ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
                        echo '{"success":"false", "code":9201,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
                state=`sudo /usr/bin/chef-server-ctl status|grep "run"|tail -1|cut -d ":" -f1`
                echo "state = $state"
                if [ "$state" = "run" ]; then
                        sudo /usr/bin/chef-server-ctl status
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true", "message":"Chef Server Already Started"}'
                        else
                                chefstart
                                if [ $? -eq 0 ]; then
                                        #crontab -u paasadmin $HOME/cronjob
                                        echo '{"code":5000,"success":"true", "message":"Chef Server Started Successfully"}'
                                else
                                        echo '{"success":"false", "code":9202,"message":"Chef Server Could Not Be Started"}'
                                fi
                        fi
                else
                        chefstart
                        if [ $? -eq 0 ]; then
                                #crontab -u paasadmin $HOME/cronjob
                                echo '{"code":5000,"success":"true", "message":"Chef Server Started Successfully"}'
                        else
                                echo '{"success":"false", "code":9202,"message":"Chef Server Could Not Be Started"}'
                        fi
                fi;;

# webserver stop case
stop)
                state=`sudo /usr/bin/chef-server-ctl status|grep "run"|tail -1|cut -d ":" -f1`
                echo "state = $state"
                if [ "$state" = "down" ]; then
                        sudo /usr/bin/chef-server-ctl status
                        if [ "$?" -eq "39" ]; then
                                echo '{"code":5000,"success":"true", "message":"Chef Server already Stopped"}'
                        else
                                crontab -r
                                chefstop
                                if [ $? -eq 0 ]; then
                                        echo '{"code":5000,"success":"true", "message":"Chef Server Stopped Successfully"}'
                                else
                                        echo '{"success":"false","code":9203, "message":"Chef Server Could Not Be Stopped"}'
                                fi
                        fi
                else
                        crontab -r
                        chefstop
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true", "message":"Chef Server Stopped Successfully"}'
                        else
                                echo '{"success":"false","code":9203, "message":"Chef Server Could Not Be Stopped"}'
                        fi
                fi;;


configure)

        old_ip=`sudo /bin/cat /etc/opscode/chef-server.rb|head -1|cut -d'"' -f2`
        echo "Old_IP = $old_ip"
        sudo /bin/sed -ie 's/'$old_ip'/'$2'/g' /etc/opscode/chef-server.rb
#        nginz_old=`/bin/cat /var/opt/opscode/nginx/etc/nginx.conf |grep server_name|head -1|awk '{print $2}'`
#        /bin/sed -ie 's/server_name '$nginz_old'/server_name '$2';/g' /var/opt/opscode/nginx/etc/nginx.conf
	sudo /vmpath/sbin/ipchanger $2 2> /dev/null &
	sudo /usr/bin/chef-server-ctl reconfigure
	if [ $? -eq 0 ]; then
		#sudo kill -9 `ps -x |grep vmpath|grep ipchanger|awk '{print $1}'`
		#sudo kill -9 `ps -x |grep "sed -ie"|grep $2|awk '{print $1}'`
		#d=`ps x |grep ipchanger|awk '{print $1}'|tr '\n' ' '`
		#for i in $d
		#do
		#	kill -9 $i
		#done
		sudo kill -9 `ps x |grep ipchanger|awk '{print $1}'|tr '\n' ' '`
		sudo /usr/bin/opscode-push-jobs-server-ctl reconfigure && sudo /usr/bin/opscode-reporting-ctl reconfigure && sudo /usr/bin/opscode-manage-ctl reconfigure
		if [ $? -eq 0 ]; then
			sudo kill -9 `ps x |grep ipchanger|awk '{print $1}'|tr '\n' ' '`
			sudo /vmpath/sbin/ipchanger $2 2> /dev/null &
			sudo /usr/bin/chef-server-ctl restart
			if [ $? -eq 0 ]; then
#				crontab -u paasadmin $HOME/cronjob
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

	sudo /usr/bin/chef-server-ctl user-create $2 a b $6 $3 --filename /home/paasadmin/keys/$2.pem
	if [ $? -eq 0 ]; then
		sudo /usr/bin/chef-server-ctl org-create $4 $5 --association_user $2 --filename /home/paasadmin/keys/$4-validator.pem
		if [ $? -eq 0 ]; then
			sudo chown -R paasadmin.paasadmin /home/paasadmin/keys
			echo '{"code":5000,"success":"true","message":"Chef Server User '$2' And Organizations '$4' Created Successfully","UserPemFilePath":"'/home/paasadmin/keys/$2.pem'","OrganizationsPemFilePath":"'/home/paasadmin/keys/$4-validator.pem'"}'
		else
			echo '{"success":"false","code":5104,"message":"Chef Server Organizations '$4' Creation Failed"}'
		fi
	else
		echo '{"success":"false","code":5105,"message":"Chef Server User '$2' Creation Failed"}'
	fi;;

reset_htpasswd)
                htpasswd -bc $HOME/htpasswd $2 $3
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Http Auth Reset Successfully"}'
                else
                        echo '{"success":"false","code":9313,"message":"Http Auth Not Be Reset"}'
                fi;;

setup)
#               mv $CATALINA_BASE/webapps/read_log.war $CATALINA_BASE/webapps/$2.war
                logval=`grep "tomcat" /etc/apache2/sites-available/default|tail -1|cut -d"/" -f5|cut -d">" -f1`
                if [ "$logval" = "tomcat" ]; then
                        sudo sed -i 's/'tomcat'/'$2'/g' /etc/apache2/sites-available/default
			mkdir $HOME/logging/$2
			ln -sf /var/log/opscode $HOME/logging/$2/opscode
			ln -sf /var/log/opscode-manage $HOME/logging/$2/opscode-manage
                        if [ -d $HOME/logging/$2 ]; then
                                sudo /etc/init.d/apache2 restart
                                echo '{"code":5000,"success":"true","message":"LOG Link Created, Setup is Successfully"}'
                        else
                                echo '{"success":"false","code":9210,"message":"LOG Link Could Not Be Create, Setup is Failed"}'
                        fi
                else
                        echo '{"success":"false","code":9211,"message":"LOG Value Could Not Be Match in Apache Server, Setup is Failed"}'
                fi;;

addsshkey)

        wget --no-check-certificate --directory-prefix=$HOME/download $2
        if [ $? -eq 0 ]; then
                fileWithExt=${2##*/}
                sudo cp $HOME/download/$fileWithExt  /home/paasuser/.ssh/authorized_keys
                sudo chmod 600 /home/paasuser/.ssh/authorized_keys
                sudo chown paasuser.paasuser /home/paasuser/.ssh/authorized_keys
                rm -rf $HOME/download/
                echo '{"code":5000,"success":"true", "message":"SSH Key Added Successfully"}'
        else
                echo '{"success":"false", "code":9202,"message":"SSH Key Download Failed"}'
                rm -rf $HOME/download/
        fi;;

esac

