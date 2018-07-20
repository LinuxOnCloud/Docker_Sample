#!/bin/bash

HOME=/home/paasadmin

export JAVA_HOME="$HOME/java"
export CATALINA_HOME="$HOME/tomcat"
export CATALINA_BASE=$CATALINA_HOME
export PATH=$PATH::$JAVA_HOME/bin:$CATALINA_HOME:$CATALINA_BASE:/home/paasadmin/tomcat/webapps/ROOT/WEB-INF

#sudo iptables -t nat -F

#sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

# start tomcat function
tomcatstart() {
        cd $CATALINA_BASE/webapps && /bin/sh ../bin/catalina.sh start
}

# stop tomcat function
tomcatstop() {
        /bin/sh $CATALINA_BASE/bin/catalina.sh stop
}


case $1 in

cmd)		
		 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":9201,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
		state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`	
		echo "state = $state"
		if [ -n "$state" ]; then  		
                        cat $HOME/cronjob|crontab
			echo '{"code":5000,"success":"true", "message":"Tomcat Already Started"}'
          	else
			tomcatstart 
			if [ $? -eq 0 ]; then
				cat $HOME/cronjob|crontab
				echo '{"code":5000,"success":"true", "message":"Tomcat Started Successfully"}'
			else
				echo '{"success":"false", "code":9202,"message":"Tomcat Could Not Be Started"}'
			fi
		fi;;

# webserver stop case
stop)
		state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`	
		echo "state = $state"
   		if [ -z "$state" ]; then
                      	crontab -r
			echo '{"code":5000,"success":"true", "message":"Tomcat already Stopped"}'
		else
                       	crontab -r
			tomcatstop
			if [ $? -eq 0 ]; then
            			echo '{"code":5000,"success":"true", "message":"Tomcat Stopped Successfully"}'
          		else
          			echo '{"success":"false","code":9203, "message":"Tomcat Could Not Be Stopped"}'
          		fi
		fi;;

# deploy and update application
#deploy)
		# download application
#          	wget --no-check-certificate --directory-prefix=$HOME/download $2
          	
#		if [ $? -eq 0 ]; then
#			rm -rf $HOME/.aws/config $HOME/url
#			state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
#	                echo "state = $state"
#        	        if [ -n "$state" ]; then
#				tomcatstop               	 
#	                else
#                	        echo "Tomcat Already Stoped"
#			fi
			
#			if [ $? -eq 0 ]; then
				# backup existing application
#				rm -rf $HOME/backup/*
#				mkdir -p $HOME/backup/
#				if [ -d $CATALINA_BASE/webapps/ROOT ]; then
#					mv $CATALINA_BASE/webapps/ROOT* $HOME/backup/.
#                else
#					echo "dir not found"
#                fi
#				if [ $? -eq 0 ]; then
					# get download file name
#					fileWithExt=${2##*/}
#					echo "file=$fileWithExt"
#					FileExt=${fileWithExt#*.}
#					d=$fileWithExt
#                    echo "file with ext =$d"
#                        if [ "$FileExt" = "tar.gz" ] || [ "$FileExt" -eq "tar.gz" ]; then
#							echo "file tar.gz ext true = $FileExt"
#                        else
#							f=`echo $FileExt | cut -d'.' -f2`
#                            FileExt=$f
#                            echo "file tar.gz ext false = $FileExt"
#                        fi

#                        echo "Archive Going to Extract = $FileExt"
					
					# extract source
#					case $FileExt in
					# extract tar.gz format
#                                        tar.gz|war.tar.gz)
#                                                tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/fname
#                                                f=`head -1 $HOME/fname|cut -d'/' -f1`
#                                                if [ -f $HOME/download/$f ]; then
#                                                        d=$f
#                                                else
#                                                        cd $HOME/download/ && mv "$f" "${f// /_}" && rm $HOME/download/*tar.gz
#                                                        d=`ls $HOME/download |awk '{ print $1 }'|head -1`
#                                                fi
#                                                echo "fname=$d";;
                                        # extract gzip format
#                                         gz|war.gz)
#                                                gunzip $HOME/download/$fileWithExt
#                                                f=`ls $HOME/download`
#                                                if [ -f $HOME/download/$f ]; then
#                                                        d=$f
#                                                else
#                                                        cd $HOME/download/ &&  mv "$f" "${f// /_}" && rm $HOME/download/*.gz
#                                                        d=`ls $HOME/download`
#                                                fi
#                                                echo "fname=$d";;
                                        # extract zip format
#                                        zip|war.zip)
#                                                unzip $HOME/download/$fileWithExt -d $HOME/download/ > $HOME/fname
#                                                sr=`grep "inflating" $HOME/fname |head -2 |cut -d'/' -f5|head -1|rev`
#                                                f=`echo $sr |rev`
#                                                echo "f=$f+1"
#                                                if [ -f $HOME/download/$f ]; then
#                                                        d=$f
#                                                else
#                                                        cd $HOME/download/ && mv "$f" "${f// /_}" && rm $HOME/download/*.zip
#                                                        d=`ls $HOME/download |awk '{ print $1 }'|head -1`
#                                                fi
#
#                                                echo "fname=$d";;

#                                        war)
#                                                d=$fileWithExt
#                                                echo "fname=$d";;
					
#					esac
					
					# move source to webapps folder
#					rm -rf $CATALINA_BASE/work/*
#					rm -rf $CATALINA_BASE/temp/*
#					rm -rf $CATALINA_BASE/webapps/ROOT*
#					mv $HOME/download/$d $CATALINA_BASE/webapps/ROOT.war
							
#					if [ $? -eq 0 ]; then
#						tomcatstart
#						sleep 20
#						state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
#				                echo "state = $state"
#				                if [ -z "$state" ]; then
							# remove downloaded and backup file
#							rm -rf $HOME/backup/ROOT*	
#							rm -rf $HOME/download	
#							echo '{"code":5000,"success":"true", "message":"Java App Deployed Successfully"}'
										

#############################################
					######### ------------######################
#						else
#							tomcatstop
#	                                                sleep 10
#							tomcatstart
#	                                                sleep 20
#							state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
#        	                                        echo "state = $state"
#	                                                if [ -n "$state" ]; then
#								rm -rf $HOME/backup/ROOT*
#        	                                                rm -rf $HOME/download
#	                                                        echo '{"code":5000,"success":"true", "message":"Java App Deployed Successfully"}'
#							else
#								rm -rf $CATALINA_BASE/webapps/ROOT*
#                        	        	                mv $HOME/backup/ROOT* $CATALINA_BASE/webapps/.
#								tomcatstop
#	                                                        sleep 10
#        		        	                	tomcatstart
#	                                        	        rm -rf $HOME/backup/ROOT*
#								rm -rf $HOME/download
#								echo '{"success":"false", "code":9204,"message":"Tomcat Could Not Be Started With New Java App, Deployment Failed"}' 
#								exit 1							
#							fi
#                                        	fi

					
#					else
						# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
#						rm -rf $CATALINA_BASE/webapps/ROOT*
#						mv $HOME/backup/ROOT* $CATALINA_BASE/webapps/.
#						tomcatstart
#						rm -rf $HOME/backup/ROOT*
#						rm -rf $HOME/download
#						echo '{"success":"false","code":9205,"message":"Java App Deployment Failed"}'
#						exit 1
#					fi 
#
#				else
#					tomcatstart
#					# remove downloaded file
#                                	rm -rf $HOME/download
#					echo '{"success":"false", "code":9206,"message":"Java App Contents For Backup Could Not Be Moved"}'						
#					exit 1
#				fi
#			else
#				tomcatstart
				# remove downloaded file
#	                	rm -rf $HOME/download
#				echo '{"success":"false","code":9207, "message":"Tomcat Could Not Be Stopped"}'
#	       	        	exit 1
#			fi
#		else
#			# remove downloaded file
#			rm -rf $HOME/download
#			rm -rf $HOME/.aws/config $HOME/url
#			echo '{"success":"false", "code":9208,"message":"Java App Download Failed"}'
#			exit 1
#		fi;;
		
createkey)

		if [ ! -d $HOME/sshkey ]; then
        		mkdir -p $HOME/sshkey
		fi

        	/usr/bin/ssh-keygen -t rsa -f $HOME/sshkey/paasuser -N ""
		sudo /sbin/katr sheppaasuserkey
	        mv $HOME/sshkey/paasuser $HOME/sshkey/paasuser.pem
        	rm $HOME/sshkey/paasuser.pub
		
		if [ ! -z /home/paasuser/.ssh/authorized_keys ]; then
			 echo '{"code":5000,"success":"true","message":"PaaSUser SSH key Created","path":"'$HOME/sshkey/paasuser.pem'"}'
                else
			echo '{"success":"false","code":9209,"message":"PaaSUser SSH key Could Not Be Created"}'	
		fi;;

setup)
		Mem=`free -m|grep Mem|awk '{print $2}'`
		Xms=`echo "$Mem / 16"|bc`
		Xmx=`echo "$Mem / 2"|bc`
		PermSize=`echo "$Mem / 16"|bc`
		MaxPermSize=`echo "$Mem / 4"|bc`
		echo 'export JAVA_OPTS="-Dfile.encoding=UTF-8 -Xms'$Xms'm -Xmx'$Xmx'm -XX:PermSize='$PermSize'm -XX:MaxPermSize='$MaxPermSize'm"' >$HOME/tomcat/bin/setenv.sh
		chmod +x $HOME/tomcat/bin/setenv.sh
#		mv $CATALINA_BASE/webapps/read_log.war $CATALINA_BASE/webapps/$2.war
		logval=`grep "tomcat" /etc/apache2/sites-available/default|tail -1|cut -d"/" -f5|cut -d">" -f1`
		if [ "$logval" = "tomcat" ]; then
			sudo sed -i 's/'tomcat'/'$2'/g' /etc/apache2/sites-available/default
			ln -sf $HOME/tomcat/logs $HOME/logging/$2
#			sudo /sbin/katr sheppaasuseratr $2
		
			if [ -L $HOME/logging/$2 ]; then
				jenkins_ip=`cat $HOME/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml|grep Url|cut -d"/" -f3`
				echo "Old Jenkins Url = $jenkins_ip; \nNew Jenkins Url = $3"
				/bin/sed -ie 's/'$jenkins_ip'/'$3'/g' $HOME/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml
				if [ $? -eq 0 ]; then
					sudo /etc/init.d/apache2 restart
					tomcatstart			
					crontab -u paasadmin $HOME/cronjob
                        		echo '{"code":5000,"success":"true","message":"LOG Link Created & Jenkins Server URL Configured, Setup is Successfully"}'
				else
					echo '{"success":"false","code":9210,"message":"Jenkins Server URL Could Not Configured"}'
				fi
	                else
        	                echo '{"success":"false","code":9210,"message":"LOG Link Could Not Be Create, Setup is Failed"}'
                	fi
		else
			echo '{"success":"false","code":9211,"message":"LOG Value Could Not Be Match in Apache Server, Setup is Failed"}'
		fi;;

addcronjob)
        	crontab -u paasadmin $HOME/cronjob
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Added Successfully"}'
	        else
        	        echo '{"success":"false","code":9212,"message":"CronJob Could Not Be Added"}'
	        fi;;

deletecronjob)
        	crontab -r
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Deleted Successfully"}'
	        else
        	        echo '{"success":"false","code":9213,"message":"CronJob Could Not Be Deleted"}'
	        fi;;

usages)
                mem=`free -m |grep "Mem"|awk '{print $3}'`
                cpu=`top -bn1 |grep "Cpu"|awk '{print $2}'|cut -d"%" -f1`
                echo '{"code":5000,"success":"true","message":"Current Resorce Usages In '$containername'","memory":"'$mem'","cpu":"'$cpu'"}'
                ;;

reset_htpasswd)
                htpasswd -bc $HOME/htpasswd $2 $3
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Http Auth Reset Successfully"}'
                else
                        echo '{"success":"false","code":9313,"message":"Http Auth Not Be Reset"}'
                fi;;

backup)
                rm -rf $HOME/App_Backup
                mkdir -p $HOME/App_Backup
                cp -arf $HOME/tomcat/webapps $HOME/App_Backup/webapps
                echo "cp -arf $HOME/tomcat/webapps $HOME/App_Backup/webapps"
                cd $HOME/App_Backup && tar czf webapps.tar.gz webapps
                if [ $? -eq 0 ]; then
                        rm -rf $HOME/App_Backup/webapps
                        echo '{"code":5000,"success":"true","message":"App Files Backup Created","appBackupPath":"'$HOME/App_Backup/webapps.tar.gz'"}'
                else
                        rm -rf $HOME/App_Backup/
                        echo '{"success":"false","code":9121,"message":"App Files Backup Could Not Be Created"}'
                fi;;

restore)
		wget --no-check-certificate --directory-prefix=$HOME/download $2


                if [ $? -eq 0 ]; then
                        rm -rf $HOME/.aws/config $HOME/url
#                wget --no-check-certificate --directory-prefix=$HOME/download $2
                        fileWithExt=${2##*/}
                        echo "file=$fileWithExt"
                        tar xzf $HOME/download/$fileWithExt -C $HOME/download/
                        if [ $? -eq 0 ]; then
                                cp -arf $HOME/tomcat/webapps $HOME/backup/
                                if [ $? -eq 0 ]; then
                                        tomcatstop
                                        rm -rf $HOME/tomcat/webapps
                                        mv $HOME/download/webapps $HOME/tomcat/webapps
                                        if [ $? -eq 0 ]; then
                                                tomcatstart
                                                echo '{"code":5000,"success":"true", "message":"PHP App Restored Successfully"}'
                                        else
                                                tomcatstop
                                                rm -rf $HOME/tomcat/webapps
                                                mv $HOME/backup/webapps $HOME/tomcat/webapps
                                                tomcatstart
                                                echo '{"success":"false","code":9304, "message":"PHP App Could Not Be Restore"}'

                                        fi
                                else
                                        echo '{"success":"false","code":9306, "message":"PHP App Contents For Backup Could Not Be Moved"}'
                                        rm -rf $HOME/backup/*
                                        rm -rf $HOME/download
                                fi
                        else
                                echo '{"success":"false","code":9306, "message":"PHP App Could Not Be Extract"}'
                                rm -rf $HOME/download
                        fi
                else
                        # remove downloaded file
                        rm -rf $HOME/download
                        rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":9308, "message":"PHP App Download Failed"}'
                        exit 1
                fi;;

artifactory)
        artif_ip=`cat $HOME/.jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml|grep url|cut -d"/" -f3|cut -d "<" -f1|cut -d ":" -f1`
        echo "Old Artifactory Url = $artif_ip; \nNew Artifactory Url = $2"
        /bin/sed -ie 's/'$artif_ip'/'$2'/g' $HOME/.jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml
#       /vmpath/sbin/config_constructor_artifactory $2
        if [ $? -eq 0 ]; then
		tomcatstop
                sleep 10
                pid=`sudo /bin/netstat -npl|grep 80|grep java|tail -1|rev|cut -d "/" -f2|awk '{print $1}'|rev`
                echo "Pid = $pid"
                if [ -n "$pid" ]; then
                        sudo kill -9 $pid
                fi
		tomcatstart
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Artifactory Server URL Configured Successfully"}'
                else
                        echo '{"success":"false","code":5101,"message":"Artifactory Server URL Could Not Configured"}'
                fi
        else
                echo '{"success":"false","code":5101,"message":"Jenkins Server Restarting Failed"}'
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

addfiles)
	wget --no-check-certificate --directory-prefix=$HOME/download $2
	if [ $? -eq 0 ]; then
                fileWithExt=${2##*/}
		FileExt=${fileWithExt#*.}
		file=$fileWithExt
		case $FileExt in
			# extract zip format
               		zip)
                        	unzip $HOME/download/$fileWithExt -d $HOME/download/ > $HOME/fname
				rm $HOME/download/$fileWithExt
				#file=`egrep "(inflating|creating)" $HOME/fname |head -2 |cut -d'/' -f5|head -1`
                                #echo "fname=$file";;
		esac

		if [ ! -d $HOME/.jenkins/app42config ]; then
			mkdir -p $HOME/.jenkins/app42config
		fi

		mv $HOME/download/* $HOME/.jenkins/app42config/.
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true", "message":"File Or Folder Added Successfully"}'
		else
			echo '{"success":"false", "code":9202,"message":"File Or Folder Could Not Be Added"}'
		fi
	else
		echo '{"success":"false", "code":9202,"message":"File Or Folder Download Failed"}'
	fi;;

addslave)
	mkdir -p $HOME/$2
#	user=`ls $HOME/.jenkins/users`
#echo "false">$HOME/.jenkins/secrets/slave-to-master-security-kill-switch
#echo "allow all /.*">$HOME/.jenkins/secrets/whitelisted-callables.d/gui.conf
echo "<?xml version='1.0' encoding='UTF-8'?>">$HOME/$2/config.xml
echo '<slave>
  <name>'$2'</name>
  <description></description>
  <remoteFS>/home/paasadmin/.jenkins/</remoteFS>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher"/>
  <label></label>
  <nodeProperties/>
  <userId>'$3'</userId>
</slave> '>>$HOME/$2/config.xml
	if [ $? -eq 0 ]; then
		mv $HOME/$2 $HOME/.jenkins/nodes/
		if [ $? -eq 0 ]; then
			tomcatstop
			sleep 10
	                pid=`sudo /bin/netstat -npl|grep 80|grep java|tail -1|rev|cut -d "/" -f2|awk '{print $1}'|rev`
        	        echo "Pid = $pid"
                	if [ -n "$pid" ]; then
                        	sudo kill -9 $pid
	                fi
        		tomcatstart
			sleep 30
			curl http://$3:$4@localhost:8080|grep "People">$HOME/jenkins-stat
			while [ "$(du -m $HOME/jenkins-stat|cut -f1)" -lt 1 ];
			do
				echo "$HOME/jenkins-stat is Empty"
				sleep 40
				curl http://$3:$4@localhost:8080|grep "People">$HOME/jenkins-stat
			done
			sleep 40
			curl http://$3:$4@localhost/computer/$2/slave-agent.jnlp >$HOME/$2-secretkey
			key_status=`cat $HOME/$2-secretkey|grep "Error report"`
			if [ -z "$key_status" ]; then
				secretkey=`cat $HOME/$2-secretkey|cut -d ">" -f19|cut -d "<" -f1`		
				rm $HOME/jenkins-stat
				rm -rf $HOME/$2 $HOME/$2-secretkey
				echo '{"code":5000,"success":"true", "message":"Slave Node Added Successfully","SlaveSecretKey":"'$secretkey'"}'
			else
				rm $HOME/jenkins-stat
				rm -rf $HOME/$2 $HOME/$2-secretkey
				echo '{"success":"false", "code":9202,"message":"Slave Node - Secretkey Not Error"}'
			fi
		else
			rm $HOME/jenkins-stat
			rm -rf $HOME/$2 $HOME/$2-secretkey
			echo '{"success":"false", "code":9202,"message":"Slave Node Folder Could Not Be Moved"}'
		fi
	else
		rm $HOME/jenkins-stat
		rm -rf $HOME/$2 $HOME/$2-secretkey
		echo '{"success":"false", "code":9202,"message":"Slave Node Could Not Be Added"}'
	fi;;
	
#runslave)
#	nohup java -jar $HOME/tomcat/webapps/ROOT/WEB-INF/slave.jar -jnlpUrl http://$2/computer/$3/slave-agent.jnlp -secret $4 &
#	sleep 5
#	stat=`cat nohup.out|tail -1|awk '{print $2}'`
#	echo "stat = $stat"
#	if [ "Connected" == $stat ]; then
#		echo "*/1 * * * * nohup $HOME/java/bin/java -jar $HOME/tomcat/webapps/ROOT/WEB-INF/slave.jar -jnlpUrl http://$2/computer/$3/slave-agent.jnlp -secret $4 &" >$HOME/slavecron
#		state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
#                echo "state = $state"
#                if [ -n "$state" ]; then
#                        cat $HOME/cronjob $HOME/slavecron|crontab
#                else
#                        cat $HOME/slavecron|crontab
#                fi
#		echo '{"code":5000,"success":"true", "message":"Slave Node Run Successfully"}'
#	else
#		echo '{"success":"false", "code":9202,"message":"Slave Node Could Not Be Run"}'
#	fi;;

#stopslave)
#	pid=`ps ax |grep $2|grep slave.jar|awk '{print $1}'`
#	echo "pid = +$pid+"
#	sudo kill -9 $pid
#	if [ $? -eq 0 ]; then
#		state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
#                echo "state = $state"
#                if [ -n "$state" ]; then
#			cat $HOME/cronjob|crontab
#		else
#			crontab -r
#		fi		
		
#		echo '{"code":5000,"success":"true", "message":"Slave Node Stopped Successfully"}'
#	else
#		echo '{"success":"false", "code":9202,"message":"Slave Node Could Not Be Stopped"}'
#	fi;;
		

bootstrap)
#	chefurl=`cat $HOME/chef/chef-repo/.chef/knife.rb |grep chef_server_url|cut -d"/" -f3`
#	if [ "$2" != "$chefurl" ]; then
#		/bin/sed -ie 's/'$chefurl'/'$2'/g' $HOME/chef/chef-repo/.chef/knife.rb
#	else
#		echo "Chef Server IP Same"
#	fi
	cd $HOME/App42Config/chef-repo && knife ssl fetch
	if [ $? -eq 0 ]; then
	#	cd $HOME/chef/chef-repo &&  knife upload .
		if [ -z $5 ]; then
			cd $HOME/App42Config/chef-repo && knife bootstrap $2 -x $3 -i $HOME/App42Config/usernodekeys/$4 --sudo
		else
			cd $HOME/App42Config/chef-repo && knife bootstrap $2 -x $3 -i $HOME/App42Config/usernodekeys/$4 --sudo -r $5
		fi
		if [ $? -eq 0 ]; then
			 echo '{"code":5000,"success":"true", "message":"Chef-Client Bootstrap Successfully"}'
		else
			echo "if [ $? -eq 0 ]; then"
			echo '{"success":"false","code":9501, "message":"Chef-Client Bootstrap Process Failed"}'
		fi
	else
		echo '{"success":"false","code":9501, "message":"Chef-Server SSL Certificate Could Not Be Fethed"}'
	fi;;


uploadapp42starter)
	#cd $HOME/chef && git clone https://github.com/acb/chef-repo.git
	#cd $HOME/chef/chef-repo && echo ".chef" >> .gitignore
        mkdir -p $HOME/App42Config/chef-repo/.chef
	if [ $? -eq 0 ]; then
		wget --no-check-certificate --directory-prefix=$HOME/App42Config/chef-repo/.chef/ $5
		if [ $? -eq 0 ]; then
			user=${5##*/}
			wget --no-check-certificate --directory-prefix=$HOME/App42Config/chef-repo/.chef/ $6
			if [ $? -eq 0 ]; then
				org=${6##*/}
echo '# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "'$2'"
client_key               "#{current_dir}/'$user'"
validation_client_name   "'$3'-validator"
validation_key           "#{current_dir}/'$org'"
chef_server_url          "https://'$4'/organizations/'$3'"
cookbook_path            ["#{current_dir}/../cookbooks"] ' > $HOME/App42Config/chef-repo/.chef/knife.rb
				cd $HOME/App42Config/chef-repo && knife ssl fetch
				if [ $? -eq 0 ]; then
					echo '{"code":5000,"success":"true", "message":"Chef Sample StarterKit Added"}'
				else
					echo '{"success":"false","code":9501, "message":"Chef Sample StarterKit Could Not Fetch SSL Certificate"}'
				fi
			else	
				echo '{"success":"false","code":9501, "message":"Chef Sample StarterKit Organization Validator PEM Download Failed"}'
			fi
		else
			echo '{"success":"false","code":9501, "message":"Chef Sample StarterKit User PEM Download Failed"}'
		fi
	else
		echo '{"success":"false","code":9501, "message":"Chef-Repo Could Not Be Git Cloned"}'
	fi;;

uploadstarterkit)
		mkdir $HOME/download
		wget --no-check-certificate --directory-prefix=$HOME/download $2
		if [ $? -eq 0 ]; then
			fileWithExt=${2##*/}
			echo "Download FileName=$fileWithExt"
			FileExt=${fileWithExt#*.}
			d=$fileWithExt
			unzip $HOME/download/$fileWithExt -d $HOME/download/ > $HOME/fname
			if [ $? -eq 0 ]; then
				cd $HOME/download/chef-repo && knife ssl fetch
				if [ $? -eq 0 ]; then
					mv $HOME/App42Config/chef-repo $HOME/App42Config/chef-repo.old
					mv $HOME/download/chef-repo $HOME/App42Config/chef-repo
					if [ $? -eq 0 ]; then
						rm -rf $HOME/App42Config/chef-repo.old $HOME/download
						echo '{"code":5000,"success":"true", "message":"Chef StarterKit Added Successfully"}'
					else
						rm -rf $HOME/App42Config/chef-repo/chef-repo.old $HOME/download
						mv $HOME/App42Config/chef-repo.old $HOME/App42Config/chef-repo
						echo '{"success":"false","code":9501, "message":""Chef StarterKit Cloud Not Be Added"}'
					fi
				else
					rm -rf $HOME/download
					echo '{"success":"false","code":9501, "message":"Chef StarterKit Could Not Fetch SSL Certificate"}'
				fi
			else
				rm -rf $HOME/download
				echo '{"success":"false","code":9501, "message":"Chef StarterKit Could Not Be Extracted"}'
			fi
		else
			rm -rf $HOME/download
			echo '{"success":"false", "code":9208,"message":"Chef StarterKit Download Failed"}'
		fi;;

uploadsshkey)
		wget --no-check-certificate --directory-prefix=$HOME/App42Config/usernodekeys $2
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true", "message":"SSH Key Added Successfully"}'
		else
			echo '{"success":"false", "code":9208,"message":"SSH Download Failed"}'
                fi;;
					
	
updatedatabags)
	if [ -d $HOME/.jenkins/jobs/App42_CookBook_Upload ]; then
		mysql=`cat $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/data_bags/dbConfig/mysql.json|grep address|awk '{print $2}'|tr -d '"'`
		warURL=`cat $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/data_bags/webConfig/tomcat.json|grep warURL|cut -d "/" -f3|cut -d ":" -f1`
		tomcaturl=`cat $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/roles/webNode.json|grep "target"|cut -d "/" -f3|cut -d ":" -f1`
		/bin/sed -ie 's/'$mysql'/'$2'/g' $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/data_bags/dbConfig/mysql.json
		if [ $? -eq 0 ]; then
			/bin/sed -ie 's/'$warURL'/'$3'/g' $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/data_bags/webConfig/tomcat.json
			if [ $? -eq 0 ]; then
				/bin/sed -ie 's/'$tomcaturl'/'$4'/g' $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/roles/webNode.json
				if [ $? -eq 0 ]; then
					ln -sf $HOME/App42Config/chef-repo/.chef $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/.chef
					cd $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/ && knife ssl fetch					
					cd $HOME/.jenkins/jobs/App42_CookBook_Upload/workspace/ && knife upload .
					if [ $? -eq 0 ]; then
						echo '{"code":5000,"success":"true", "message":"DataBags Update Successfully"}'
					else
						echo '{"success":"false", "code":9208,"message":"Chef Server CookBook Could Not Be Uploaded"}'
					fi
				else	
					echo '{"success":"false", "code":9208,"message":"DataBags Could Not Be Updated"}'
				fi
			else
				echo '{"success":"false", "code":9208,"message":"DataBags Could Not Be Updated"}'
			fi
		else
			echo '{"success":"false", "code":9208,"message":"DataBags Could Not Be Updated"}'
		fi
	else
		echo '{"success":"false", "code":9208,"message":"App42_CookBook Job Could Not Be Found"}'
	fi;;

	
addjob)
#	artif_ip=`cat $HOME/.jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml|grep url|cut -d"/" -f3|cut -d "<" -f1|cut -d ":" -f1`
#	/bin/sed -ie 's/'$artif_ip'/'$2'/g' 
	
	/bin/sed -ie 's/92.246.242.230/'$2'/g' $HOME/App42_Sample/ACME_Test/config.xml
	if [ $? -eq 0 ]; then
		/bin/sed -ie 's/92.246.242.232/'$3'/g' $HOME/App42_Sample/ACME_Test/config.xml
		if [ $? -eq 0 ]; then
			rm $HOME/App42_Sample/ACME_Test/config.xmle
			cp -arf $HOME/App42_Sample/* $HOME/.jenkins/jobs/.
			if [ $? -eq 0 ]; then
				tomcatstop
				sleep 20
				tomcatstart
				echo '{"code":5000,"success":"true", "message":"App42_Sample Jobs Added Successfully"}'
			else
				echo '{"success":"false", "code":9208,"message":"App42_Sample Jobs Could Not Be Added"}'
			fi
		else
			echo '{"success":"false", "code":9208,"message":"App42_Sample Jmeter_IP Could Not Be Replaced"}'
		fi
	else
		echo '{"success":"false", "code":9208,"message":"App42_Sample Selenium_IP Could Not Be Replaced"}'
	fi;;

getjobconfig)
	cp $HOME/.jenkins/jobs/ACME_Sample/config.xml	$HOME/App42_Sample/ACME_Sample_config.xml
	if [ $? -eq 0 ]; then
		echo '{"code":5000,"success":"true","message":"App42 Sample Job Config File","JobConfigPath":"'$HOME/App42_Sample/ACME_Sample_config.xml'"}'
	elae
		echo '{"success":"false", "code":9208,"message":"App42_Sample Job Config Could Not Be Copied"}'
	fi;;

updatejob)
		mkdir $HOME/download
                wget --no-check-certificate --directory-prefix=$HOME/download $2
                if [ $? -eq 0 ]; then
                        fileWithExt=${2##*/}
                        echo "Download FileName=$fileWithExt"
                        FileExt=${fileWithExt#*.}
                        d=$fileWithExt
			if [ "xml" == "$FileExt" ]; then
				cp $HOME/.jenkins/jobs/ACME_Sample/config.xml $HOME/backup/.
				cp $HOME/download/$2 $HOME/.jenkins/jobs/ACME_Sample/config.xml
				if [ $? -eq 0 ]; then
					tomcatstop
	                                sleep 20
        	                        tomcatstart
					rm -rf $HOME/download $HOME/backup/*
                	                echo '{"code":5000,"success":"true", "message":"App42_Sample Jobs Updated Successfully"}'
                        	else
                                	echo '{"success":"false", "code":9208,"message":"App42_Sample Jobs Could Not Be Updated"}'
					rm -rf $HOME/download $HOME/backup/*
                        	fi
			else
				echo '{"success":"false", "code":9208,"message":"App42_Sample Jobs Config Downloaded File Is Not In XML Format"}'
				rm -rf $HOME/download $HOME/backup/*
			fi
		else
			echo '{"success":"false", "code":9208,"message":"App42_Sample Jobs Config Could Not Be Download"}'
			rm -rf $HOME/download $HOME/backup/*
		fi;;

*)
		echo '{"success":"false", "code":9214,"message":"Invalid Command - Jenkins Master Server"}'
                ;;
esac
