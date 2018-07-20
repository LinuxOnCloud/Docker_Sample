#!/bin/bash

host=`hostname`
HOME=/home/paasadmin
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/bin



# start nginx function
rubystart() {
	/home/paasadmin/unicorn/init/unicorn start
	sudo /etc/init.d/nginx start
}

# stop nginx function
rubystop() {
	/home/paasadmin/unicorn/init/unicorn stop
	sudo /etc/init.d/nginx stop
}


case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 			${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":9601,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
	state=`sudo netstat -npl|grep  nginx|grep 8080|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        state1=`sudo netstat -npl|grep unicorn|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
        echo "state=$state+1"
        echo "state1=$state1+1"
	if [ -n "$state" ] && [ -n "$state1" ]; then
		echo '{"code":5000,"success":"true", "message":"Nginx Already Started"}'
	else
		rubystop
		sleep 2
		rubystart
		if [ $? -eq 0 ]; then
			crontab -u paasadmin $HOME/cronjob
			echo '{"code":5000,"success":"true", "message":"Nginx Started Successfully"}'
     		else
			echo '{"success":"false","code":9602, "message":"Nginx Could Not Be Started"}'
		fi
    	fi;;

# webserver stop case
stop)
	state=`sudo netstat -npl|grep  nginx|grep 8080|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        state1=`sudo netstat -npl|grep unicorn|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
        echo "state=$state+1"
        echo "state1=$state1+1"

	if [ -z "$state" ] && [ -z "$state1" ]; then
		echo '{"code":5000,"success":"true", "message":"Nginx Already Stopped"}'
	else
		crontab -r
		rubystop
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true", "message":"Nginx Stopped Successfully"}'
		else
			echo '{"success":"false","code":9603, "message":"Nginx Could Not Be Stopped"}'
		fi
  	fi;;

# deploy and update application
deploy)
                # download application
		wget --no-check-certificate --directory-prefix=$HOME/download $2

                if [ $? -eq 0 ]; then
                        rm -rf $HOME/.aws/config $HOME/url
			state=`sudo netstat -npl|grep  nginx|grep 8080|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        		state1=`sudo netstat -npl|grep unicorn|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
		        echo "state=$state+1"
        		echo "state1=$state1+1"
	        	if [ -n "$state" ] && [ -n "$state1" ]; then
		                rubystop
#				pkill -9 nginx
#				pkill -9 unicorn
	        	else
                		echo "Nginx Already Started"
			fi
			if [ $? -eq 0 ]; then
                        	# backup existing application
				rm -rf $HOME/backup/*
				mkdir -p $HOME/backup/
                                if [ -d $HOME/rubyapp/app ]; then
                                        mv  $HOME/rubyapp/app $HOME/backup/.
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
                                                mv $HOME/download/$d $HOME/rubyapp/app
                                                rm -rf $HOME/rubyapp/app/log
                                                ln -sf $HOME/log $HOME/rubyapp/app/log
                                        else
                                                mkdir -p $HOME/rubyapp/app
                                                mv $HOME/download/$d $HOME/rubyapp/app
                                                rm -rf $HOME/rubyapp/app/log
                                                ln -sf $HOME/log $HOME/rubyapp/app/log
                                        fi
					
					if [ -f $HOME/rubyapp/app/config/database.yml ]; then
                                                cd $HOME/rubyapp/app/ && sudo  /usr/local/bin/bundle install --without development:test 2>> $HOME/rubyapp/app/log/production.log
                                                rake assets:clean 2>> $HOME/rubyapp/app/log/production.log
                                                rake assets:precompile RAILS_ENV=production 2>> $HOME/rubyapp/app/log/production.log
                                                rake db:create RAILS_ENV=production 2>> $HOME/rubyapp/app/log/production.log
                                                rake db:migrate RAILS_ENV=production 2>> $HOME/rubyapp/app/log/production.log
                                                rake db:seed RAILS_ENV=production 2>> $HOME/rubyapp/app/log/production.log
                 #                               cd $HOME/rubyapp/rails_logger/ && sudo /usr/local/bin/bundle update
                                                sudo chown -R 1001.1001 $HOME/rubyapp/app
                                        else
                                                cd $HOME/rubyapp/app && sudo /usr/local/bin/bundle install --without development:test 2>> $HOME/rubyapp/app/log/production.log
                                                rake assets:clean 2>> $HOME/rubyapp/app/log/production.log
                                                rake assets:precompile RAILS_ENV=production 2>> $HOME/rubyapp/app/log/production.log
                #                                cd $HOME/rubyapp/rails_logger/ && sudo /usr/local/bin/bundle update
                                                sudo chown -R 1001.1001 $HOME/rubyapp/app
                                        fi

					if [ $? -eq 0 ]; then
						rubystart	
						sleep 20
						state=`sudo netstat -npl|grep  nginx|grep 8080|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
					        state1=`sudo netstat -npl|grep unicorn|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
					        echo "state=$state+1"
					        echo "state1=$state1+1"
					        if [ -n "$state" ] && [ -n "$state1" ]; then
							# remove downloaded and backup file
							rm -rf $HOME/download
							rm -rf $HOME/backup/app*
							rm -rf $HOME/fname
							echo '{"code":5000,"success":"true", "message":"Ruby App Deployed Successfully"}'	
										

#############################################
					######### ------------######################
						else
							rubystop
							#pkill -9 nginx
			                                #pkill -9 unicorn
	                                                sleep 10
							rubystart
	                                                sleep 20
							state=`sudo netstat -npl|grep  nginx|grep 8080|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                        	                        state1=`sudo netstat -npl|grep unicorn|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
                	                                echo "state=$state+1"
        	                                        echo "state1=$state1+1"
	                                                if [ -n "$state" ] && [ -n "$state1" ]; then
								rm -rf $HOME/download
                	                                        rm -rf $HOME/backup/app*
        	                                                rm -rf $HOME/fname
	                                                        echo '{"code":5000,"success":"true", "message":"Ruby App Deployed Successfully"}'
							else
								rm -rf $HOME/rubyapp/app*
                		                                mv $HOME/backup/app $HOME/rubyapp/
		                                                rm -rf $HOME/rubyapp/app/log
                                                		ln -sf $HOME/log $HOME/rubyapp/app/log
								rubystop
								#pkill -9 nginx
	                                                        #pkill -9 unicorn
	                                                        sleep 10
                                		                rubystart
                		                                rm -rf $HOME/backup/app*
		                                                rm -rf $HOME/download
								rm -rf $HOME/fname
								echo '{"success":"false","code":9604, "message":"Nginx Could Not Be Started With New Ruby App, Deployment Failed"}'
								exit 1
							fi
                                        	fi

					
					else
						# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
						rm -rf $HOME/rubyapp/app*
                                                mv $HOME/backup/app $HOME/rubyapp/
                                                rm -rf $HOME/rubyapp/app/log
                                                ln -sf $HOME/log $HOME/rubyapp/app/log
						rubystart
						rm -rf $HOME/backup/app*
						rm -rf $HOME/download
						rm -rf $HOME/fname
						echo '{"success":"false","code":9605, "message":"Ruby App Deployment Failed"}'
					fi 

				else
					rubystart
					# remove downloaded file
					rm -rf $HOME/download
					echo '{"success":"false","code":9606, "message":"Ruby App Contents For Backup Could Not Be Moved"}'
					exit 1
				fi
			else
				rubystart
				# remove downloaded file
				rm -rf $HOME/download
				echo '{"success":"false","code":9607, "message":"Nginx Could Not Be Stopped"}'
	       	        	exit 1
			fi
		else

			# remove downloaded file
			rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
			echo '{"success":"false","code":9608, "message":"Ruby App Download Failed"}'
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
                        echo '{"success":"false","code":9609,"message":"PaaSUser SSH key Could Not Be Created"}'
                fi;;

setup)
		logval=`grep "tomcat" /etc/apache2/sites-available/default|tail -1|cut -d"/" -f5|cut -d">" -f1`
		if [ "$logval" = "tomcat" ]; then
			sudo sed -i 's/'tomcat'/'$2'/g' /etc/apache2/sites-available/default
			ln -sf $HOME/log $HOME/logging/$2
			#sudo /sbin/katr sheppaasuseratr
			if [ -L $HOME/logging/$2 ]; then
				sudo /etc/init.d/apache2 restart
				rubystart
				crontab -u paasadmin $HOME/cronjob
				echo '{"code":5000,"success":"true","message":"LOG Link Created, Setup is Successfully"}'
			else
				echo '{"success":"false","code":9610,"message":"LOG Link Could Not Be Create, Setup is Failed"}'
                 	fi
		else
			echo '{"success":"false","code":9611,"message":"LOG Value Could Not Be Match in Apache Server, Setup is Failed"}'
		fi;;

addcronjob)
        	crontab -u paasadmin $HOME/cronjob
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Added Successfully"}'
	        else
        	        echo '{"success":"false","code":9612,"message":"CronJob Could Not Be Added"}'
	        fi;;

deletecronjob)
        	crontab -r
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Deleted Successfully"}'
	        else
        	        echo '{"success":"false","code":9613,"message":"CronJob Could Not Be Deleted"}'
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
                echo '{"success":"false", "code":9614,"message":"Invalid Command"}'
                ;;

esac

