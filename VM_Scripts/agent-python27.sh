#!/bin/bash

host=`hostname`

# start nginx function
pythonstart() {
        /etc/init.d/django start
        sudo /etc/init.d/nginx start
}

# stop nginx function
pythonstop() {
        /etc/init.d/django stop
        sudo /etc/init.d/nginx stop
        sudo /root/atr_set
}

case $1 in

cmd)
                $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}                   ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
                        echo '{"success":"false", "code":6101,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
	state=`sudo netstat -npl|grep nginx |grep 80 |grep -v worker |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	state1=`sudo netstat -npl|grep python |grep 8000 |head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
        echo "nginx=$state+1"
        echo "Python=$state1+1"
        if [ -n "$state" ] && [ -n "$state1" ]; then
                echo '{"code":5000,"success":"true", "message":"Nginx Already Started"}'
        else
                pythonstart
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Nginx Started Successfully"}'
                else
                        echo '{"success":"false","code":6102, "message":"Nginx Could Not Be Started"}'
                fi
        fi;;

# webserver stop case
stop)
	state=`sudo netstat -npl|grep nginx |grep 80 |grep -v worker |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        state1=`sudo netstat -npl|grep python |grep 8000 |head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
        echo "nginx=$state+1"
        echo "Python=$state1+1"
        if [ -z "$state" ] && [ -z "$state1" ]; then
                echo '{"code":5000,"success":"true", "message":"Nginx Already Stopped"}'
        else
                pythonstop
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
                        pythonstop
			state=`sudo netstat -npl|grep nginx |grep 80 |grep -v worker |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		        state1=`sudo netstat -npl|grep python |grep 8000 |head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
		        echo "nginx=$state+1"
		        echo "Python=$state1+1"
		        if [ -n "$state" ] && [ -n "$state1" ]; then
				echo "app stoping"
				pythonstop
			else
				echo "Nginx Already Started"
			fi

                        if [ $? -eq 0 ]; then
                                # backup existing application
				rm -rf $HOME/backup/*
                                mkdir -p $HOME/backup/
                                if [ -d /var/www/pythonapp ]; then
                                        mv  /var/www/pythonapp $HOME/backup/.
                		else
					echo "dir not found"
		                fi

                                if [ $? -eq 0 ]; then
                                        # get download file name
                                        fileWithExt=${2##*/}
                                        echo "file=$fileWithExt"
                                        FileExt=${fileWithExt#*.}
                                        #d=`echo "$fileWithExt" | cut -d'.' -f1
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
                                                mv $HOME/download/$d /var/www/pythonapp
						rm -rf /var/www/pythonapp/logs
						ln -sf /opt/log /var/www/pythonapp/logs
                                        else
                                                mkdir -p /var/www/pythonapp
                                                mv $HOME/download/$d /var/www/pythonapp
						rm -rf /var/www/pythonapp/logs
                                                ln -sf /opt/log /var/www/pythonapp/logs
                                        fi
					
                                        if [ $? -eq 0 ]; then
						setting=`cat /var/www/pythonapp/manage.py | grep settings | cut -d'"' -f4 | cut -d'.' -f1`
                                        	dbtype_mysql=`cat /var/www/pythonapp/$setting/settings.py | grep ENGINE| cut -d"'" -f4 | grep mysql|rev|cut -d"." -f1|rev`
                                        	dbtype_postgres=`cat /var/www/pythonapp/$setting/settings.py|grep ENGINE|cut -d"'" -f4|grep postgres|rev|cut -d "." -f1|rev`
						echo "setting = $setting , dbtype_mysql=$dbtype_mysql , dbtype_postgres=$dbtype_postgres"

                                        	if [ -n "$dbtype_mysql" ] || [ -n "$dbtype_postgres" ]; then
                                                	cd /var/www/pythonapp/ && python manage.py syncdb --noinput &>> /opt/log/django.log
							echo "cd /var/www/pythonapp/ && python manage.py syncdb --noinput"
                                        	fi
                                                
						pythonstart
						sleep 20
						state=`sudo netstat -npl|grep nginx |grep 80 |grep -v worker |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
						state1=`sudo netstat -npl|grep python |grep 8000 |head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
						echo "nginx=$state+1"
						echo "Python=$state1+1"
						if [ -n "$state" ] && [ -n "$state1" ]; then
							# remove downloaded and backup file
                                                        rm -rf $HOME/download
                                                        rm -rf $HOME/backup/pythonapp*
                                                        rm -rf $HOME/fname
                                                        echo '{"code":5000,"success":"true", "message":"Python App Deployed Successfully"}'


#############################################
                                        ######### ------------######################
                                                else
							pythonstop
							sleep 10
							pythonstart
							sleep 20
							state=`sudo netstat -npl|grep nginx |grep 80 |grep -v worker |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
							state1=`sudo netstat -npl|grep python |grep 8000 |head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
							echo "nginx=$state+1"
							echo "Python=$state1+1"
							if [ -n "$state" ] && [ -n "$state1" ]; then
								# remove downloaded and backup file
								rm -rf $HOME/download
								rm -rf $HOME/backup/pythonapp*
								rm -rf $HOME/fname
								echo '{"code":5000,"success":"true", "message":"Python App Deployed Successfully"}'
							else
								rm -rf /var/www/pythonapp*
		                                                mv $HOME/backup/pythonapp /var/www/pythonapp
								pythonstop
								sleep 10
								pythonstart
								rm -rf $HOME/backup/pythonapp*
								rm -rf $HOME/download
								rm -rf $HOME/fname
								echo '{"success":"false","code":6104, "message":"Nginx Could Not Be Started With New Python App, Deployment Failed"}'
								exit 1
							fi
						fi							

                                        else
                                                # remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
						pythonstop
                                                rm -rf /var/www/pythonapp*
                                                mv $HOME/backup/pythonapp /var/www/pythonapp
					#	rm -rf /var/www/demo/log
                                                #ln -sf /opt/log /var/www/demo/log
                                                pythonstart
                                                rm -rf $HOME/backup/pythonapp*
                                                rm -rf $HOME/download
                                                echo '{"success":"false","code":6105, "message":"Python App Deployment Failed"}'
                                        fi

                                else
                                        pythonstart
                                        # remove downloaded file
                                        rm -rf $HOME/download
                                        echo '{"success":"false","code":6106, "message":"Python App Contents For Backup Could Not Be Moved"}'
                                        exit 1
                                fi
                        else
                                pythonstart
                                # remove downloaded file
                                rm -rf $HOME/download
                                echo '{"success":"false","code":6107, "message":"App Could Not Be Stopped"}'
                                exit 1
			fi
                else

                        # remove downloaded file
                        rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":6108, "message":"Python App Download Failed"}'
                        exit 1
        fi;;


*)
                echo 'Usage: {cmd|start|stop|deploy}'
                echo '{"success":"false", "code":6109,"message":"Invalid Command"}'
                ;;
esac
