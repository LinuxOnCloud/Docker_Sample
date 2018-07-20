#!/bin/bash



# start apache function
phpstart() {
	sudo /etc/init.d/apache2 start
}

# stop apache function
phpstop() {
        sudo /etc/init.d/apache2 stop
#	sudo pkill -kill apache2
}

case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":9301,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
		state=`sudo netstat -npl|grep apache2|grep 8080|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		if [ -n "$state" ]; then 
                        echo '{"code":5000,"success":"true", "message":"Apache Already Started"}'
		else
			phpstart
			if [ $? -eq 0 ]; then
			crontab -u paasadmin $HOME/cronjob
                        echo '{"code":5000,"success":"true", "message":"Apache Started Successfully"}'
	                else
                        echo '{"success":"false","code":9302, "message":"Apache Could Not Be Started"}'
			fi
                fi;;

# webserver stop case
stop)
		state=`sudo netstat -npl|grep apache2|grep 8080|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		if [ -z "$state" ]; then
			echo '{"code":5000,"success":"true", "message":"Apache already Stopped"}'
		else
			crontab -r
			phpstop
	                if [ $? -eq 0 ]; then
        	                echo '{"code":5000,"success":"true", "message":"Apache Stopped Successfully"}'
                	else
                	        echo '{"success":"false","code":9303, "message":"Apache Could Not Be Stopped"}'
			fi
                fi;;

# deploy and update application
deploy)
		# download application
                wget --no-check-certificate --directory-prefix=$HOME/download $2

                if [ $? -eq 0 ]; then
			rm -rf $HOME/.aws/config $HOME/url
			state=`sudo netstat -npl|grep apache2|grep 8080|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	                if [ -n "$state" ]; then
        	                phpstop
			else
	                        echo "Apache Already Started"
			fi
                        if [ $? -eq 0 ]; then
				mkdir -p $HOME/backup/
				# backup existing application
				rm -rf $HOME/backup/*
				if [ -d $HOME/phpapp/php ]; then
				mv  $HOME/phpapp/php $HOME/backup/.
                	else
				echo "dir not found"
                	fi
                    if [ $? -eq 0 ]; then
					# get download file name
					fileWithExt=${2##*/}
					echo "file=$fileWithExt"
					FileExt=${fileWithExt#*.}
					#d=`echo "$fileWithExt" | cut -d'.' -f1`
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
                        	tar.gz)
                                	tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/fname
									rm $HOME/download/$fileWithExt
                                    count=`ls -l $HOME/download/|wc -l`
                                    if [ $count = 2 ]; then
										f=`head -1 $HOME/fname|cut -d'/' -f1`
                                        if [ -d $HOME/download/$f ]; then
											d=$f
										else
											cd $HOME/download/ && mv "$f" "${f// /_}" && rm $HOME/download/*.tar.gz
											d=`ls $HOME/download |awk '{ print $1 }'|head -1`
										fi
                                    else
										mkdir -p $HOME/download/$USER
                                        mv $HOME/download/* $HOME/download/$USER/ 2> /dev/null
                                        d=$USER
									fi
									echo "fname=$d";;
                                                
			# extract gzip format
                        	gz)
                                	gunzip $HOME/download/$fileWithExt
                                        f=`ls $HOME/download`
                                        if [ -f $HOME/download/$f ]; then
						d=$f
                                     	else
						cd $HOME/download/ && mv "$f" "${f// /_}" && rm $HOME/download/*.gz
                                                d=`ls $HOME/download`
                                        fi
					echo "fname=$d";;
                                        
                   	# extract zip format
                        	zip)
                                	unzip $HOME/download/$fileWithExt -d $HOME/download/ > $HOME/fname
					rm $HOME/download/$fileWithExt
                                        count=`ls -l $HOME/download/|wc -l`
                                        if [ $count = 2 ]; then
                                                f=`egrep "(inflating|creating)" $HOME/fname |head -2 |cut -d'/' -f5|head -1`
                                                if [ -d $HOME/download/$f ]; then
                                                        d=$f
                                                else
                                                        cd $HOME/download/ && mv "$f" "${f// /_}" && rm $HOME/download/*.zip
                                                        d=`ls $HOME/download |awk '{ print $1 }'|head -1`
                                                fi
                                        else
                                                mkdir -p $HOME/download/$USER
                                                mv $HOME/download/* $HOME/download/$USER/ 2> /dev/null
                                                d=$USER
                                        fi
                                        echo "fname=$d";;
                                        
			esac
				
					# move source to php folder
					if [ -d $HOME/download/$d ]; then
                                        	mv $HOME/download/$d $HOME/phpapp/php
					else
						mkdir -p $HOME/phpapp/php/
						mv $HOME/download/$d $HOME/phpapp/php/index.php
					fi

                                        if [ $? -eq 0 ]; then
                                                #echo '{"code":5000,"success":"true", "message":"App extracted and moved"}'
#						ln -sf $HOME/phpapp/$depid.php  $HOME/phpapp/php/$depid.php
                                                phpstart
						sleep 20
						state=`sudo netstat -npl|grep apache2|grep 8080|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
			                        if [ -n "$state" ]; then
							# remove downloaded and backup file
							rm -rf $HOME/download
							rm -rf $HOME/backup/php*
                                                        echo '{"code":5000,"success":"true", "message":"PHP App Deployed Successfully"}'


#############################################
                                        ######### ------------######################
                                                else
							phpstop
                                                	sleep 10
							phpstart
                                                	sleep 20
                                        	        state=`sudo netstat -npl|grep apache2|grep 8080|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                                	                if [ -n "$state" ]; then
                        	                                # remove downloaded and backup file
                	                                        rm -rf $HOME/download
        	                                                rm -rf $HOME/backup/php*
	                                                        echo '{"code":5000,"success":"true", "message":"PHP App Deployed Successfully"}'
							else
								rm -rf $HOME/phpapp/php
		                                                mv $HOME/backup/php $HOME/phpapp/php
								phpstop
	                                                        sleep 10
                                		                phpstart
                		                                rm -rf $HOME/backup/php*
		                                                rm -rf $HOME/download
	                                                        echo '{"success":"false","code":9304, "message":"Apache Could Not Be Started With New PHP App, Deployment Failed"}'
								exit 1
							fi
                                                fi

                                        else
						# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
                                                rm -rf $HOME/phpapp/php
						mv $HOME/backup/php $HOME/phpapp/php
#						ln -sf $HOME/phpapp/$depid.php  $HOME/phpapp/php/$depid.php
						phpstart
						rm -rf $HOME/backup/php*
						rm -rf $HOME/download
                                                echo '{"success":"false","code":9305, "message":"PHP App Deployment Failed"}'
						exit 1
                                        fi
										
                                else
					phpstart
					# remove downloaded file
					rm -rf $HOME/download
                                        echo '{"success":"false","code":9306, "message":"PHP App Contents For Backup Could Not Be Moved"}'
                                        exit 1
                                fi
								
                        else
				phpstart
				# remove downloaded file
				rm -rf $HOME/download
                                echo '{"success":"false","code":9307, "message":"Apache Could Not Be Stopped"}'
                                exit 1
                        fi
						
                else
			# remove downloaded file
			rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":9308, "message":"PHP App Download Failed"}'
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
                        echo '{"success":"false","code":9309,"message":"PaaSUser SSH key Could Not Be Created"}'
                fi;;

				
setup)
                logval=`grep "tomcat" /opt/apache2/conf/httpd.conf |tail -1|cut -d"/" -f5|cut -d">" -f1`
                if [ "$logval" = "tomcat" ]; then
                        sudo sed -i 's/'tomcat'/'$2'/g' /opt/apache2/conf/httpd.conf
                        ln -sf /var/log/apache2 $HOME/logging/$2
                        echo "$2" > $HOME/DepID
#                        sudo /sbin/katr sheppaasuseratr
                        if [ -L $HOME/logging/$2 ]; then
                                sudo /etc/init.d/httpd restart
                                phpstart
                                crontab -u paasadmin $HOME/cronjob

                                echo '{"code":5000,"success":"true","message":"LOG Link Created, Setup is Successfully"}'
                        else
                                echo '{"success":"false","code":9310,"message":"LOG Link Could Not Be Create, Setup is Failed"}'
                        fi
                else
                        echo '{"success":"false","code":9311,"message":"LOG Value Could Not Be Match in Apache Server, Setup is Failed"}'
                fi;;

addcronjob)
        	crontab -u paasadmin $HOME/cronjob
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Added Successfully"}'
	        else
        	        echo '{"success":"false","code":9312,"message":"CronJob Could Not Be Added"}'
	        fi;;

deletecronjob)
        	crontab -r
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Deleted Successfully"}'
	        else
        	        echo '{"success":"false","code":9313,"message":"CronJob Could Not Be Deleted"}'
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


*)
                echo 'Usage: {cmd|start|stop|deploy}'
                echo '{"success":"false", "code":9314,"message":"Invalid Command"}'
                ;;
				
esac
