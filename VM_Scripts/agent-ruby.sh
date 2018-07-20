#!/bin/bash

host=`hostname`

# start nginx function
rubystart() {
        cd /opt/nginx/sbin/ && ./nginx
}

# stop nginx function
rubystop() {
        #sudo ps aux |grep Passenger|awk '{print $2}' > $HOME/Passenger.pid
       # head -3 $HOME/Passenger.pid >  $HOME/F.pid
      #  sudo ps aux |grep nginx|awk '{print $2}' > $HOME/nginx.pid
     #   head -2 $HOME/nginx.pid >>  $HOME/F.pid
    #    /usr/bin/tr '\n' ' ' < $HOME/F.pid > $HOME/P.pid
   #     pid=`cat $HOME/P.pid`
  #      sudo kill  $pid
 #       rm -rf /tmp/passenger*
#	rm -rf  $HOME/F.pid $HOME/P.pid $HOME/nginx.pid $HOME/Passenger.pid
	sudo pkill -9 Passenger
        sudo pkill -9 nginx
	sudo /root/atr_set
}


case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 			${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":6101,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
	state=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	echo "state=$state+1"
	if [ -n "$state" ]; then
		echo '{"code":5000,"success":"true", "message":"Nginx Already Started"}'
	else
		rubystart
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true", "message":"Nginx Started Successfully"}'
     		else
			echo '{"success":"false","code":6102, "message":"Nginx Could Not Be Started"}'
		fi
    	fi;;

# webserver stop case
stop)
	state=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        echo "state=$state+1"
	if [ -z "$state" ]; then
		echo '{"code":5000,"success":"true", "message":"Nginx Already Stopped"}'
	else
		rubystop
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true", "message":"Nginx Stopped Successfully"}'
		else
			echo '{"success":"false","code":6103, "message":"Nginx Could Not Be Stopped"}'
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
			state=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		        echo "state=$state+1"
		        if [ -n "$state" ]; then
				rubystop
				sudo pkill -9 Passenger
				sudo pkill -9 nginx
				echo "nginx kill"
			else
				echo "Nginx Already Started"
			fi
			if [ $? -eq 0 ]; then
                        	# backup existing application
				mkdir -p $HOME/backup/
				if [ -d /var/www/demo ]; then
					mv  /var/www/demo $HOME/backup/.
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

					# move source to workspace folder
					if [ -d $HOME/download/$d ]; then	
						mv $HOME/download/$d /var/www/demo
						rm -rf /var/www/demo/log
						ln -sf /opt/log /var/www/demo/log
					else
						mkdir -p /var/www/demo
						mv $HOME/download/$d /var/www/demo/
                                                rm -rf /var/www/demo/log
                                                ln -sf /opt/log /var/www/demo/log
					fi
					
					if [ -f /var/www/demo/config/database.yml ]; then
  						cd /var/www/demo/ && sudo  /usr/local/bin/bundle install --without development:test 2>> /var/www/demo/log/production.log
						rake assets:clean 2>> /var/www/demo/log/production.log
						rake assets:precompile RAILS_ENV=production 2>> /var/www/demo/log/production.log
						rake db:create RAILS_ENV=production 2>> /var/www/demo/log/production.log
						rake db:migrate RAILS_ENV=production 2>> /var/www/demo/log/production.log
						rake db:seed RAILS_ENV=production 2>> /var/www/demo/log/production.log
						sudo /sbin/chown -R $host.$host /var/www/demo/ 
					else
						cd /var/www/demo/ && sudo /usr/local/bin/bundle install --without development:test 2>> /var/www/demo/log/production.log
						rake assets:clean 2>> /var/www/demo/log/production.log
						rake assets:precompile RAILS_ENV=production 2>> /var/www/demo/log/production.log
						sudo /sbin/chown -R $host.$host /var/www/demo/
					fi					
					if [ $? -eq 0 ]; then
						rubystart	
						sleep 20
						state=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                        			echo "state=$state+1"
			                        if [ -n "$state" ]; then
							# remove downloaded and backup file
							rm -rf $HOME/download
							rm -rf $HOME/backup/demo*
							rm -rf $HOME/fname
							echo '{"code":5000,"success":"true", "message":"Ruby App Deployed Successfully"}'	
										

#############################################
					######### ------------######################
						else
							rubystop
                                                        sudo pkill -9 nginx
							sudo pkill -9 Passenger
                                                        sleep 10
                                                        rubystart
                                                        sleep 20
							state=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
						        echo "state=$state+1"
							if [ -n "$state" ]; then
								# remove downloaded and backup file
					                        rm -rf $HOME/download
						                rm -rf $HOME/backup/app*
							        rm -rf $HOME/fname
								echo '{"code":5000,"success":"true", "message":"Ruby App Deployed Successfully"}'
							else
								rm -rf /var/www/demo*
                                		                mv $HOME/backup/demo /var/www/demo
                		                                rm -rf /var/www/demo/log
		                                                ln -sf /opt/log /var/www/demo/log
								rubystop
								sudo pkill -9 nginx
							        sudo pkill -9 Passenger
								sleep 10
		                                                rubystart
                					        rm -rf $HOME/backup/app*
								rm -rf $HOME/download
							        rm -rf $HOME/fname
								echo '{"success":"false","code":6104, "message":"Nginx Could Not Be Started With New Ruby App, Deployment Failed"}'
								exit 1
							fi
                                         	fi

					
					else
						# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
						rm -rf /var/www/demo*
						mv $HOME/backup/demo /var/www/demo
						rm -rf /var/www/demo/log
                                         	ln -sf /opt/log /var/www/demo/log
						rubystart
						rm -rf $HOME/backup/demo*
						rm -rf $HOME/download
						echo '{"success":"false","code":6105, "message":"Ruby App Deployment Failed"}'
					fi 

				else
					rubystart
					# remove downloaded file
					rm -rf $HOME/download
					echo '{"success":"false","code":6106, "message":"Ruby App Contents For Backup Could Not Be Moved"}'
					exit 1
				fi
			else
				rubystart
				# remove downloaded file
				rm -rf $HOME/download
				echo '{"success":"false","code":6107, "message":"Nginx Could Not Be Stopped"}'
	       	        	exit 1
			fi
		else

			# remove downloaded file
			rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
			echo '{"success":"false","code":6108, "message":"Ruby App Download Failed"}'
			exit 1
	fi;;
	

*)
                echo 'Usage: {cmd|start|stop|deploy}'
                echo '{"success":"false", "code":6109,"message":"Invalid Command"}'
                ;;

esac

