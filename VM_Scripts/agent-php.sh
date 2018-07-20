#!/bin/bash

host=`hostname`

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
			echo '{"success":"false", "code":6201,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
		state=`sudo netstat -npl|grep apache2|grep 80|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		echo "Apache=$state+1"
		if [ -n "$state" ]; then 
                        echo '{"code":5000,"success":"true", "message":"Apache Already Started"}'
		else
			phpstart
			if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Apache Started Successfully"}'
	                else
                        echo '{"success":"false","code":6202, "message":"Apache Could Not Be Started"}'
			fi
                fi;;

# webserver stop case
stop)
		state=`sudo netstat -npl|grep apache2|grep 80|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                echo "Apache=$state+1"
		if [ -z "$state" ]; then
			echo '{"code":5000,"success":"true", "message":"Apache already Stopped"}'
		else
			phpstop
	                if [ $? -eq 0 ]; then
        	                echo '{"code":5000,"success":"true", "message":"Apache Stopped Successfully"}'
                	else
                	        echo '{"success":"false","code":6203, "message":"Apache Could Not Be Stopped"}'
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
                #wget --no-check-certificate --directory-prefix=$HOME/download $2

                if [ $? -eq 0 ]; then
			rm -rf $HOME/.aws/config $HOME/url
			state=`sudo netstat -npl|grep apache2|grep 80|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
			if [ -n "$state" ]; then
				phpstop
			else
				echo "Apache Already Started"
			fi

                        if [ $? -eq 0 ]; then
				rm -rf $HOME/backup/*
				mkdir -p $HOME/backup/
				# backup existing application
				if [ -d /var/www/php ]; then
					sudo /bin/chown -R 1001.33 /var/www	
					mv  /var/www/php $HOME/backup/.
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
                                        	mv $HOME/download/$d /var/www/php
					else
						mkdir -p /var/www/php/
						mv $HOME/download/$d /var/www/php/index.php
					fi

                                        if [ $? -eq 0 ]; then
                                                #echo '{"code":5000,"success":"true", "message":"App extracted and moved"}'
						sudo /bin/chown -R 1001.33 /var/www
                                                phpstart
						sleep 20
						state=`sudo netstat -npl|grep apache2|grep 80|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
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
        		                                state=`sudo netstat -npl|grep apache2|grep 80|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                        			        if [ -n "$state" ]; then
                 						rm -rf $HOME/download
							        rm -rf $HOME/backup/php*
								echo '{"code":5000,"success":"true", "message":"PHP App Deployed Successfully"}'
							else
								rm -rf /var/www/*
		                                                mv $HOME/backup/php /var/www/php
								sudo /bin/chown -R 1001.33 /var/www
								phpstop
								sleep 10
				                                phpstart
						                rm -rf $HOME/backup/php*
								rm -rf $HOME/download
								echo '{"success":"false","code":6204, "message":"Apache Could Not Be Started With New PHP App, Deployment Failed"}'
								exit 1
							fi
                                                fi

                                        else
						# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
                                                rm -rf /var/www/*
						mv $HOME/backup/php /var/www/php
						sudo /bin/chown -R 1001.33 /var/www
						phpstart
						rm -rf $HOME/backup/php*
						rm -rf $HOME/download
                                                echo '{"success":"false","code":6205, "message":"PHP App Deployment Failed"}'
						exit 1
                                        fi
										
                                else
					phpstart
					# remove downloaded file
					rm -rf $HOME/download
                                        echo '{"success":"false","code":6206, "message":"PHP App Contents For Backup Could Not Be Moved"}'
                                        exit 1
                                fi
								
                        else
				phpstart
				# remove downloaded file
				rm -rf $HOME/download
                                echo '{"success":"false","code":6207, "message":"Apache Could Not Be Stopped"}'
                                exit 1
                        fi
						
                else
			# remove downloaded file
			rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":6208, "message":"PHP App Download Failed"}'
                        exit 1
                fi;;
				
*)
                echo 'Usage: {cmd|start|stop|deploy}'
                echo '{"success":"false", "code":6209,"message":"Invalid Command"}'
                ;;
				
esac
