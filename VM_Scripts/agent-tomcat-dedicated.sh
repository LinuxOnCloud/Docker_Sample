#!/bin/bash

HOME=/home/paasadmin

export JAVA_HOME="$HOME/java"
export CATALINA_HOME="$HOME/tomcat"
export CATALINA_BASE=$CATALINA_HOME
export PATH=$PATH::$JAVA_HOME/bin:$CATALINA_HOME:$CATALINA_BASE

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
			echo '{"code":5000,"success":"true", "message":"Tomcat Already Started"}'
          	else
			tomcatstart 
			if [ $? -eq 0 ]; then
				crontab -u paasadmin $HOME/cronjob
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
deploy)
                echo $2 > $HOME/url
                rgn=`cat $HOME/url|cut -d "/" -f1`
                if [ "$rgn" = "cdn.vmpath.com" ]; then
                        region=us-west-2
                else
                        region=us-east-1
                fi

                if [ ! -d $HOME/.aws/ ]; then
                        mkdir -p $HOME/.aws/
                fi

echo "[default]
output = json
region = $region
aws_access_key_id = xxxxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxx" >$HOME/.aws/config
                # download application
                aws s3 cp s3://$2 $HOME/download/

		# download application
#          	wget --no-check-certificate --directory-prefix=$HOME/download $2
          	
		if [ $? -eq 0 ]; then
			rm -rf $HOME/.aws/config $HOME/url
			state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	                echo "state = $state"
        	        if [ -n "$state" ]; then
				tomcatstop               	 
	                else
                	        echo "Tomcat Already Started"
			fi
			
			if [ $? -eq 0 ]; then
				# backup existing application
				rm -rf $HOME/backup/*
				mkdir -p $HOME/backup/
				if [ -d $CATALINA_BASE/webapps/ROOT ]; then
					mv $CATALINA_BASE/webapps/ROOT* $HOME/backup/.
                else
					echo "dir not found"
                fi
				if [ $? -eq 0 ]; then
					# get download file name
					fileWithExt=${2##*/}
					echo "file=$fileWithExt"
					FileExt=${fileWithExt#*.}
					d=$fileWithExt
                    echo "file with ext =$d"
                        if [ "$FileExt" = "tar.gz" ] || [ "$FileExt" -eq "tar.gz" ]; then
							echo "file tar.gz ext true = $FileExt"
                        else
							f=`echo $FileExt | cut -d'.' -f2`
                            FileExt=$f
                            echo "file tar.gz ext false = $FileExt"
                        fi

                        echo "Archive Going to Extract = $FileExt"
					
					# extract source
					case $FileExt in
					# extract tar.gz format
                                        tar.gz|war.tar.gz)
                                                tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/fname
                                                f=`head -1 $HOME/fname|cut -d'/' -f1`
                                                if [ -f $HOME/download/$f ]; then
                                                        d=$f
                                                else
                                                        cd $HOME/download/ && mv "$f" "${f// /_}" && rm $HOME/download/*tar.gz
                                                        d=`ls $HOME/download |awk '{ print $1 }'|head -1`
                                                fi
                                                echo "fname=$d";;
                                        # extract gzip format
                                         gz|war.gz)
                                                gunzip $HOME/download/$fileWithExt
                                                f=`ls $HOME/download`
                                                if [ -f $HOME/download/$f ]; then
                                                        d=$f
                                                else
                                                        cd $HOME/download/ &&  mv "$f" "${f// /_}" && rm $HOME/download/*.gz
                                                        d=`ls $HOME/download`
                                                fi
                                                echo "fname=$d";;
                                        # extract zip format
                                        zip|war.zip)
                                                unzip $HOME/download/$fileWithExt -d $HOME/download/ > $HOME/fname
                                                sr=`grep "inflating" $HOME/fname |head -2 |cut -d'/' -f5|head -1|rev`
                                                f=`echo $sr |rev`
                                                echo "f=$f+1"
                                                if [ -f $HOME/download/$f ]; then
                                                        d=$f
                                                else
                                                        cd $HOME/download/ && mv "$f" "${f// /_}" && rm $HOME/download/*.zip
                                                        d=`ls $HOME/download |awk '{ print $1 }'|head -1`
                                                fi

                                                echo "fname=$d";;

                                        war)
                                                d=$fileWithExt
                                                echo "fname=$d";;
					
					esac
					
					# move source to webapps folder
					rm -rf $CATALINA_BASE/work/*
					rm -rf $CATALINA_BASE/temp/*
					rm -rf $CATALINA_BASE/webapps/ROOT*
					mv $HOME/download/$d $CATALINA_BASE/webapps/ROOT.war
							
					if [ $? -eq 0 ]; then
						tomcatstart
						sleep 20
						state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
				                echo "state = $state"
				                if [ -z "$state" ]; then
							# remove downloaded and backup file
							rm -rf $HOME/backup/ROOT*	
							rm -rf $HOME/download	
							echo '{"code":5000,"success":"true", "message":"Java App Deployed Successfully"}'
										

#############################################
					######### ------------######################
						else
							tomcatstop
	                                                sleep 10
							tomcatstart
	                                                sleep 20
							state=`sudo netstat -npl|grep java|grep 8080 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        	                                        echo "state = $state"
	                                                if [ -n "$state" ]; then
								rm -rf $HOME/backup/ROOT*
        	                                                rm -rf $HOME/download
	                                                        echo '{"code":5000,"success":"true", "message":"Java App Deployed Successfully"}'
							else
								rm -rf $CATALINA_BASE/webapps/ROOT*
                        	        	                mv $HOME/backup/ROOT* $CATALINA_BASE/webapps/.
								tomcatstop
	                                                        sleep 10
        		        	                	tomcatstart
	                                        	        rm -rf $HOME/backup/ROOT*
								rm -rf $HOME/download
								echo '{"success":"false", "code":9204,"message":"Tomcat Could Not Be Started With New Java App, Deployment Failed"}' 
								exit 1							
							fi
                                        	fi

					
					else
						# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
						rm -rf $CATALINA_BASE/webapps/ROOT*
						mv $HOME/backup/ROOT* $CATALINA_BASE/webapps/.
						tomcatstart
						rm -rf $HOME/backup/ROOT*
						rm -rf $HOME/download
						echo '{"success":"false","code":9205,"message":"Java App Deployment Failed"}'
						exit 1
					fi 

				else
					tomcatstart
					# remove downloaded file
                                	rm -rf $HOME/download
					echo '{"success":"false", "code":9206,"message":"Java App Contents For Backup Could Not Be Moved"}'						
					exit 1
				fi
			else
				tomcatstart
				# remove downloaded file
	                	rm -rf $HOME/download
				echo '{"success":"false","code":9207, "message":"Tomcat Could Not Be Stopped"}'
	       	        	exit 1
			fi
		else
			# remove downloaded file
			rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
			echo '{"success":"false", "code":9208,"message":"Java App Download Failed"}'
			exit 1
		fi;;
		
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
#		mv $CATALINA_BASE/webapps/read_log.war $CATALINA_BASE/webapps/$2.war
		logval=`grep "tomcat" /etc/apache2/sites-available/default|tail -1|cut -d"/" -f5|cut -d">" -f1`
		if [ "$logval" = "tomcat" ]; then
			sudo sed -i 's/'tomcat'/'$2'/g' /etc/apache2/sites-available/default
			ln -sf $HOME/tomcat/logs $HOME/logging/$2
			sudo /sbin/katr sheppaasuseratr $2
		
			if [ -L $HOME/logging/$2 ]; then
				sudo /etc/init.d/apache2 restart
				tomcatstart			
				crontab -u paasadmin $HOME/cronjob
                        	echo '{"code":5000,"success":"true","message":"LOG Link Created, Setup is Successfully"}'
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
		
*)
                echo 'Usage: {cmd|start|stop|deploy|createkey|setup}'
		echo '{"success":"false", "code":9214,"message":"Invalid Command"}'
                ;;
esac
