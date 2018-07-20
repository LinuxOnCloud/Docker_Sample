#!/bin/bash

host=`hostname`

export NODE_ENV="production"
export PORT=8080

nodestart() {
	cat /var/www/nodeapps/package.json |jq '.scripts.start' >$HOME/123
	sed -ie 's/node//g' $HOME/123
	startup=`cat $HOME/123|cut -d'"' -f2|tr -d ' '`
	cat /var/www/nodeapps/package.json |jq '.main' >$HOME/1234
	sed -ie 's/node//g' $HOME/1234
	startup22=`cat $HOME/1234|cut -d'"' -f2|tr -d ' '`
        echo "startup file = $startup / $startup22"
	if [ null = $startup ] && [ null = $startup22 ]; then
		
		cd /var/www/nodeapps/ && node node_modules/forever/bin/forever start -l /var/www/nodeapps/logs/forever.log -a /var/www/nodeapps/index.js
	else
		if [ null = $startup22 ]; then
			cd /var/www/nodeapps/ && node node_modules/forever/bin/forever start -l /var/www/nodeapps/logs/forever.log -a /var/www/nodeapps/$startup
		else	                
        	        cd /var/www/nodeapps/ && node node_modules/forever/bin/forever start -l /var/www/nodeapps/logs/forever.log -a /var/www/nodeapps/$startup22
		fi
	fi
		
	sudo /etc/init.d/nginx start
}


nodestop() {
 	node node_modules/forever/bin/forever stopall
	sudo /etc/init.d/nginx stop
	sudo /root/atr_set
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
	webserver=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
	mynodeapp=`sudo netstat -npl|grep node|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
	echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"
	if [ -n "$webserver" ] && [ -n "$mynodeapp" ]; then
	        echo '{"code":5000,"success":"true", "message":"Node.js Already Started"}'
	else
		nodestop
		sleep 2
		nodestart				
		sleep 1
		mynodeappport=`sudo nmap -p8080 localhost|grep tcp |awk '{ print $2 }'`
		webserverport=`sudo nmap -p80 localhost|grep tcp |awk '{ print $2 }'`
                if [ $mynodeappport = open ] && [ $webserverport = open ]; then
                        echo "started without error"
			echo '{"code":5000,"success":"true", "message":"Node.js Started Successfully"}'
                else
			
			echo '{"success":"false","code":8402, "message":"Node.js Could Not Be Started"}'
		fi
        fi
;;

# webserver stop case
stop)
	webserver=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
        mynodeapp=`sudo netstat -npl|grep node|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
        echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"
        if [ -z "$webserver" ] && [ -z "$mynodeapp" ]; then
                echo '{"code":5000,"success":"true", "message":"Node.js Already Stopped"}'
	else
		nodestop
		mynodeappport=`sudo nmap -p8080 localhost|grep tcp |awk '{ print $2 }'`
                webserverport=`sudo nmap -p80 localhost|grep tcp |awk '{ print $2 }'`
		if [ $mynodeappport = closed ] && [ $webserverport = closed ]; then
			echo '{"code":5000,"success":"true", "message":"Node.js Stopped Successfully"}'
        	else
			echo '{"success":"false","code":8403, "message":"Node.js Could Not Be Stopped"}'
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
			nodestop
			webserver=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		        mynodeapp=`sudo netstat -npl|grep node|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
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
                                if [ -d /var/www/nodeapps ]; then
                                	mv /var/www/nodeapps $HOME/backup/.
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
					rm -rf $HOME/download/.git
                                        rm -rf $HOME/download/__MACOSX
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
	                            		mv $HOME/download/$d /var/www/nodeapps
					else
						mkdir -p  /var/www/nodeapps
						mkdir -p  /var/www/nodeapps/node_modules
						mv $HOME/download/$d /var/www/nodeapps/index.js
					fi						

					if [ $? -eq 0 ]; then
                                                #echo '{"code":5000,"success":"true", "message":"App extracted and moved"}'
						ln -sf /opt/logs /var/www/nodeapps/logs
        	                                cd /var/www/nodeapps && npm install
						if [ $? -eq 0 ]; then
						        echo "npm run ok"
						else
						        cd /var/www/nodeapps && npm install
						fi
	                                        cp -arf $HOME/node_modules/forever/ /var/www/nodeapps/node_modules/
                	                        sudo /sbin/chown -R $host.$host /var/www/
						if [ -d /var/www/nodeapps/node_modules/compound/bin  ]; then
							node_modules/compound/bin/compound.js db update
						fi					
						nodestart
						sleep 20
						webserver=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
						mynodeapp=`sudo netstat -npl|grep node|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
						echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"
						if [ -n "$webserver" ] && [ -n "$mynodeapp" ]; then
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
							webserver=`sudo netstat -npl|grep nginx|grep 80|grep -v worker|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
						        mynodeapp=`sudo netstat -npl|grep node|grep 8080|head -1|cut -d"/" -f1|rev|awk '{print $1}'|rev`
					                echo "webserver=$webserver+1, mynodeapp=$mynodeapp+1"
							if [ -n "$webserver" ] && [ -n "$mynodeapp" ]; then
								rm -rf $HOME/download
								rm -rf $HOME/backup/*
								echo '{"code":5000,"success":"true", "message":"Node.js App Deployed Successfully"}'
							else
								rm -rf /var/www/nodeapps
                		                                mv $HOME/backup/nodeapps /var/www/nodeapps
		                                                ln -sf /opt/logs /var/www/nodeapps/logs
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
                                                rm -rf /var/www/nodeapps
                                                mv $HOME/backup/nodeapps /var/www/nodeapps
						ln -sf /opt/logs /var/www/nodeapps/logs
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
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":8408, "message":"Node.js App Download Failed"}'
                        exit 1
                fi;;
*)
                echo 'Usage: {cmd|start|stop|deploy}'
                echo '{"success":"false", "code":8409,"message":"Invalid Command"}'
                ;;
                                
esac
