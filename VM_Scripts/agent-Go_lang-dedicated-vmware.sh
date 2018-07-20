#!/bin/bash

#host=`hostname`
#export NODE_ENV="production"
#export PORT=8080
export GOROOT=/opt/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=$HOME/app/goapp

gostart() {
#	cd /var/www/goapp && nohup go run main.go &
	/etc/init.d/go-lang start
		
	sudo /etc/init.d/nginx start
}


gostop() {
#	go_pid=`sudo ps -ef |grep go-build|grep command|awk '{print $2}'`
#	sudo kill -9 $go_pid
	/etc/init.d/go-lang stop
# 	go node_modules/forever/bin/forever stopall
	sudo /etc/init.d/nginx stop
	sudo pkill -9 nginx
}

case $1 in

cmd)                
                $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}                         ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
                if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
                        echo '{"success":"false", "code":8401,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
	webserver=`sudo netstat -npl |grep 80|grep nginx|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	mygoapp=`sudo netstat -npl |grep 3000|grep main|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	echo "nginx=$webserver+1"
	echo "GoApp=$mygoapp+1"
	if [ -n "$webserver" ] && [ -n "$mygoapp" ]; then
	        echo '{"code":5000,"success":"true", "message":"GO Already Started"}'
	else
		gostop
		sleep 2
		gostart		
		sleep 20
		webserver=`sudo netstat -npl |grep 80|grep nginx|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		mygoapp=`sudo netstat -npl |grep 3000|grep main|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        	echo "nginx=$webserver+1"
	        echo "GoApp=$mygoapp+1"
                if [ -n "$webserver" ] && [ -n "$mygoapp" ]; then
			crontab -u paasadmin $HOME/cronjob
                        echo "started without error"
			echo '{"code":5000,"success":"true", "message":"GO Started Successfully"}'
			exit
                else
			
			echo '{"success":"false","code":8402, "message":"GO Could Not Be Started"}'
		fi
        fi
;;

# webserver stop case
stop)
	webserver=`sudo netstat -npl |grep 80|grep nginx|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	mygoapp=`sudo netstat -npl |grep 3000|grep main|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        echo "nginx=$webserver+1"
	echo "GoApp=$mygoapp+1"

        if [ -z "$webserver" ] && [ -z "$mygoapp" ]; then
                echo '{"code":5000,"success":"true", "message":"GO Already Stopped"}'
	else
		crontab -r
		gostop
		webserver=`sudo netstat -npl |grep 80|grep nginx|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		mygoapp=`sudo netstat -npl |grep 3000|grep main|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                echo "nginx=$webserver+1"
                echo "GoApp=$mygoapp+1"
		if [ -z "$webserver" ] && [ -z "$mygoapp" ]; then
			echo '{"code":5000,"success":"true", "message":"GO Stopped Successfully"}'
        	else
			echo '{"success":"false","code":8403, "message":"GO Could Not Be Stopped"}'
		fi
  	fi;;

# deploy and update application
deploy)
                # download application
                wget --no-check-certificate --directory-prefix=$HOME/download $2

                if [ $? -eq 0 ]; then
			webserver=`sudo netstat -npl |grep 80|grep nginx|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	                mygoapp=`sudo netstat -npl |grep 3000|grep main|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                	echo "nginx=$webserver+1"
        	        echo "GoApp=$mygoapp+1"
	                if [ -n "$webserver" ] && [ -n "$mygoapp" ]; then
				gostop
			else
				echo "Go App Already Started"
			fi
                        if [ $? -eq 0 ]; then
                                rm -rf $HOME/backup/*
                                mkdir -p $HOME/backup/
                                # backup existing application
                                if [ -d $HOME/app/goapp ]; then
                                	mv $HOME/app/goapp $HOME/backup/.
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
                                
                                        # move source to go.js folder
					if [ -d $HOME/download/$d ]; then
	                            		mv $HOME/download/$d $HOME/app/goapp
					else
						mkdir -p  $HOME/app/goapp
						#mkdir -p  /var/www/goapp/node_modules
						mv $HOME/download/$d $HOME/app/goapp/
					fi						

					if [ $? -eq 0 ]; then
                                                #echo '{"code":5000,"success":"true", "message":"App extracted and moved"}'
						ln -sf $HOME/logs $HOME/app/goapp/log
        	                                cd $HOME/app/goapp && go get
#	                                        cp -arf $HOME/go_modules/forever/ /var/www/nodeapps/node_modules/
                	                        #sudo /sbin/chown -R $host.$host /var/www/
#						if [ -d /var/www/goapps/node_modules/compound/bin  ]; then
#							go_modules/compound/bin/compound.js db update
#						fi					
						gostart
						sleep 20
						webserver=`sudo netstat -npl |grep 80|grep nginx|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
					        mygoapp=`sudo netstat -npl |grep 3000|grep main|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
					        echo "nginx=$webserver+1"
					        echo "GoApp=$mygoapp+1"
					        if [ -n "$webserver" ] && [ -n "$mygoapp" ]; then
                                                        # remove downloaded and backup file
                                                        rm -rf $HOME/download
                                                        rm -rf $HOME/backup/*
                                                        echo '{"code":5000,"success":"true", "message":"GO App Deployed Successfully"}'


#############################################
                                        ######### ------------######################
                                                else
							gostop
                                                        sleep 10
							gostart
                	                                sleep 20
        	                                        webserver=`sudo netstat -npl |grep 80|grep nginx|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	                                                mygoapp=`sudo netstat -npl |grep 3000|grep main|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                                                	echo "nginx=$webserver+1"
                                        	        echo "GoApp=$mygoapp+1"
                                	                if [ -n "$webserver" ] && [ -n "$mygoapp" ]; then
                        	                                # remove downloaded and backup file
                	                                        rm -rf $HOME/download
        	                                                rm -rf $HOME/backup/*
	                                                        echo '{"code":5000,"success":"true", "message":"GO App Deployed Successfully"}'
							else
								rm -rf $HOME/app/goapp
		                                                mv $HOME/backup/goapp $HOME/app/goapp
                                                		ln -sf $HOME/logs $HOME/app/goapp/log
								gostop
	                                                        sleep 10
                                		                gostart
                		                                rm -rf $HOME/backup/goapp*
			                        		rm -rf $HOME/download
								echo '{"success":"false","code":8404, "message":"GO App Deployed But GO Could Not Be Started"}'
                                        	                exit 1
							fi
                                                fi

					else
                                                # remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
                                                rm -rf /var/www/goapp
                                                mv $HOME/backup/goapp $HOME/app/goapp
						ln -sf /opt/logs $HOME/app/goapp/log
						gostart
                                                rm -rf $HOME/backup/goapp*
                                                rm -rf $HOME/download
                                                echo '{"success":"false","code":8405, "message":"GO App Deployment Failed"}'
                                                exit 1
                                        fi
                                                                                
				else
                                        gostart
                                        # remove downloaded file
                                        rm -rf $HOME/download
                                        echo '{"success":"false","code":8406, "message":"GO App Contents For Backup Could Not Be Moved"}'
                                        exit 1
                                fi
                                                                
			else
                                gostart
                                # remove downloaded file
                                rm -rf $HOME/download
                                echo '{"success":"false","code":8407, "message":"GO Could Not Be Stopped"}'
                                exit 1
                        fi
                                                
		else
                        # remove downloaded file
                        rm -rf $HOME/download
			rm -rf $HOME/download/ $HOME/url
                        echo '{"success":"false","code":8408, "message":"GO App Download Failed"}'
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
                        echo '{"success":"false","code":8409,"message":"PaaSUser SSH key Could Not Be Created"}'
                fi;;


setup)
                logval=`grep "tomcat" /etc/apache2/sites-available/default|tail -1|cut -d"/" -f5|cut -d">" -f1`
                if [ "$logval" = "tomcat" ]; then
                        sudo sed -i 's/'tomcat'/'$2'/g' /etc/apache2/sites-available/default
                        ln -sf $HOME/logs $HOME/logging/$2
                        #sudo /sbin/katr sheppaasuseratr
                        if [ -L $HOME/logging/$2 ]; then
                                sudo /etc/init.d/apache2 restart
				gostart
                                crontab -u paasadmin $HOME/cronjob
                                echo '{"code":5000,"success":"true","message":"LOG Link Created, Setup is Successfully"}'
                        else
                                echo '{"success":"false","code":8410,"message":"LOG Link Could Not Be Create, Setup is Failed"}'
                        fi
                else
                        echo '{"success":"false","code":8411,"message":"LOG Value Could Not Be Match in Apache Server, Setup is Failed"}'
                fi;;

addcronjob)
                crontab -u paasadmin $HOME/cronjob
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"CronJob Added Successfully"}'
                else
                        echo '{"success":"false","code":9129,"message":"CronJob Could Not Be Added"}'
                fi;;

deletecronjob)
                crontab -r
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"CronJob Deleted Successfully"}'
                else
                        echo '{"success":"false","code":9130,"message":"CronJob Could Not Be Deleted"}'
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
                echo '{"success":"false", "code":8409,"message":"Invalid Command"}'
                ;;
                                
esac
