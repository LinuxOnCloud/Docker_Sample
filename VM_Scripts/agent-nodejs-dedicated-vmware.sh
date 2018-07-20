#!/bin/bash

export NODE_ENV="production"
export PORT=8080

nodestart() {
	cat $HOME/app/nodeapps/package.json |jq '.scripts.start' >$HOME/123
	sed -ie 's/node//g' $HOME/123
	startup=`cat $HOME/123|cut -d'"' -f2|tr -d ' '`
	cat $HOME/app/nodeapps/package.json |jq '.main' >$HOME/1234
	sed -ie 's/node//g' $HOME/1234
	startup22=`cat $HOME/1234|cut -d'"' -f2|tr -d ' '`
        echo "startup file = $startup / $startup22"
        if [ null = $startup ] && [ null = $startup22 ]; then

		cd $HOME/app/nodeapps/ && node node_modules/forever/bin/forever start -l $HOME/app/nodeapps/logs/forever.log -a $HOME/app/nodeapps/index.js
	else
		if [ null = $startup22 ]; then
               		cd $HOME/app/nodeapps/ && node node_modules/forever/bin/forever start -l $HOME/app/nodeapps/logs/forever.log -a $HOME/app/nodeapps/$startup
		else
			cd $HOME/app/nodeapps/ && node node_modules/forever/bin/forever start -l $HOME/app/nodeapps/logs/forever.log -a $HOME/app/nodeapps/$startup22
		fi
	fi
		
#	cd $HOME/app/logger/ && node node_modules/forever/bin/forever start -l $HOME/app/logger/forever-logger.log -a $HOME/app/logger/logger.js
	sudo /etc/init.d/nginx start
	rm $HOME/123 $HOME/1234 $HOME/1234e $HOME/123e
	
}


nodestop() {
 	node node_modules/forever/bin/forever stopall
	sudo /etc/init.d/nginx stop
	
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
	webserver=`sudo netstat -npl|grep nginx|grep 8081|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	mynodeapp=`sudo netstat -npl|grep nodejs|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`

	echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"

	if [ -n "$webserver" ] && [ -n "$mynodeapp" ]; then
	        echo '{"code":5000,"success":"true", "message":"Node.js Already Started"}'
	else
		
		nodestop
		sleep 2
		nodestart				
		sleep 1
		mynodeappport=`nmap -p8080 localhost|grep tcp |awk '{ print $2 }'`
		webserverport=`nmap -p8081 localhost|grep tcp |awk '{ print $2 }'`
		echo "listen = $listenport+1"
                if [ $mynodeappport = open ] && [ $webserverport = open ]; then
			crontab -u paasadmin $HOME/cronjob
                        echo "started without error"
			echo '{"code":5000,"success":"true", "message":"Node.js Started Successfully"}'
                else
			
			echo '{"success":"false","code":8402, "message":"Node.js Could Not Be Started"}'
		fi
        fi
;;

# webserver stop case
stop)
	webserver=`sudo netstat -npl|grep nginx|grep 8081|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        mynodeapp=`sudo netstat -npl|grep nodejs|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
	echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"
	
        if [ -z "$webserver" ] && [ -z "$mynodeapp" ]; then
                echo '{"code":5000,"success":"true", "message":"Node.js Already Stopped"}'
	else
		crontab -r
		nodestop
		mynodeappport=`nmap -p8080 localhost|grep tcp |awk '{ print $2 }'`
                webserverport=`nmap -p8081 localhost|grep tcp |awk '{ print $2 }'`
		if [ $mynodeappport = closed ] && [ $webserverport = closed ]; then
			echo '{"code":5000,"success":"true", "message":"Node.js Stopped Successfully"}'
        	else
			echo '{"success":"false","code":8403, "message":"Node.js Could Not Be Stopped"}'
		fi
  	fi;;

# deploy and update application
deploy)
                # download application
                wget --no-check-certificate --directory-prefix=$HOME/download $2

                if [ $? -eq 0 ]; then
			
			webserver=`ps -ef | grep nginx |grep master | awk '{print $2}'`
        mynodeapp=`ps -ef | grep nodejs |grep nodeapps|tail -1|awk '{print $2}'`

        echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"

        if [ -n "$webserver" ] && [ -n "$mynodeapp" ]; then
			nodestop
else
		echo "Node.js Already Stopped"
	fi


                        if [ $? -eq 0 ]; then
				rm -rf $HOME/backup/*
                                mkdir -p $HOME/backup/
                                # backup existing application
                                if [ -d $HOME/app/nodeapps ]; then
                                	mv $HOME/app/nodeapps $HOME/backup/.
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
					rm -rf $HOME/download/.git
                                        rm -rf $HOME/download/__MACOSX
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
					rm -rf $HOME/download/.git
                                        rm -rf $HOME/download/__MACOSX
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
                                
                                        # move source to node.js folder
					if [ -d $HOME/download/$d ]; then
	                            		mv $HOME/download/$d $HOME/app/nodeapps
					else
						mkdir -p  $HOME/app/nodeapps
						mkdir -p  $HOME/app/nodeapps/node_modules
						mv $HOME/download/$d $HOME/app/nodeapps/index.js
					fi						

					if [ $? -eq 0 ]; then
                                                #echo '{"code":5000,"success":"true", "message":"App extracted and moved"}'
						ln -sf $HOME/logs $HOME/app/nodeapps/logs
        	                                cd $HOME/app/nodeapps && npm install
                                                if [ $? -eq 0 ]; then
                                                        echo "npm run ok"
                                                else
        	                                	cd $HOME/app/nodeapps && npm install
                                                fi
	                                        cp -arf $HOME/node_modules/forever/ $HOME/app/nodeapps/node_modules/
                	                        
						if [ -d $HOME/app/nodeapps/node_modules/compound/bin  ]; then
							node_modules/compound/bin/compound.js db update
						fi					
						nodestart
						sleep 20
						webserver=`sudo netstat -npl|grep nginx|grep 8081|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
					        mynodeapp=`sudo netstat -npl|grep nodejs|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
						echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"
					        if [ -n "$webserver" ] && [ -n "$mynodeapp" ]; then
                                                
                                        #        if [ $? -eq 0 ]; then
                                                        # remove downloaded and backup file
                                                        rm -rf $HOME/download
                                                        rm -rf $HOME/backup/*
                                                        echo '{"code":5000,"success":"true", "message":"Node.js App Deployed Successfully"}'


#############################################
                                        ######### ------------######################
                                                else
							nodestop
							sleep 10
							nodestart
							sleep 20
							webserver=`sudo netstat -npl|grep nginx|grep 8081|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                        	                        mynodeapp=`sudo netstat -npl|grep nodejs|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
                	                                echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"
        	                                        if [ -n "$webserver" ] && [ -n "$mynodeapp" ]; then
								rm -rf $HOME/download
        	                                                rm -rf $HOME/backup/*
	                                                        echo '{"code":5000,"success":"true", "message":"Node.js App Deployed Successfully"}'
							else
								rm -rf $HOME/app/nodeapps
		                                                mv $HOME/backup/nodeapps $HOME/app/nodeapps
                                        		        ln -sf $HOME/logs $HOME/app/nodeapps/logs
								nodestop
	                                                        sleep 10
                        		                        nodestart
        		                                        rm -rf $HOME/backup/nodeapps*
	                	                                rm -rf $HOME/download
								echo '{"success":"false","code":8404, "message":"Node.js App Deployed But Node.js Could Not Be Started"}'
                                                        	exit 1
							fi
                                                fi

					else
                                                # remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
                                                rm -rf $HOME/app/nodeapps
                                                mv $HOME/backup/nodeapps $HOME/app/nodeapps
						ln -sf $HOME/logs $HOME/app/nodeapps/logs
						nodestart
                                                rm -rf $HOME/backup/nodeapps*
                                                rm -rf $HOME/download
                                                echo '{"success":"false","code":8405, "message":"Node.js App Deployment Failed"}'
                                                exit 1
                                        fi
                                                                                
				else
                                        nodestart
                                        # remove downloaded file
                                        rm -rf $HOME/download
                                        echo '{"success":"false","code":8406, "message":"Node.js App Contents For Backup Could Not Be Moved"}'
                                        exit 1
                                fi
                                                                
			else
                                nodestart
                                # remove downloaded file
                                rm -rf $HOME/download
                                echo '{"success":"false","code":8407, "message":"Node.js Could Not Be Stopped"}'
                                exit 1
                        fi
                                                
		else
                        # remove downloaded file
                        rm -rf $HOME/download
                        echo '{"success":"false","code":8408, "message":"Node.js App Download Failed"}'
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
				nodestart
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
                echo '{"success":"false", "code":8412,"message":"Invalid Command"}'
                ;;
                                
esac
