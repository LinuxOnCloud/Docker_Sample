#!/bin/bash
HOME=/home/paasadmin
export JAVA_HOME=/opt/java
export PATH=$PATH:$JAVA_HOME/bin

sudo iptables -t nat -F

sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 843 -j REDIRECT --to-port 8430

# start apache function
warpstart() {
	/home/paasadmin/appwarp-conf/appwarp start
}

# stop apache function
warpstop() {
	/home/paasadmin/appwarp-conf/appwarp stop
}


case $1 in

cmd)                
                $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}                 ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
                if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
                        echo '{"success":"false", "code":9101,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
                ud=`netstat -npl|grep udp |grep 12346|cut -d'/' -f1|rev|awk '{print $1}'|rev`
echo "udp=$ud"

		if [ -n "$ud" ]; then
			echo '{"code":5000,"success":"true", "message":"Warp App Already Started"}'
		else
			warpstart
			sleep 25
			ud1=`netstat -npl|grep udp |grep 12346|cut -d'/' -f1|rev|awk '{print $1}'|rev`
			if [ -n "$ud1" ]; then
				crontab -u paasadmin $HOME/cronjob

# && [ -n $udp ]; then
				echo '{"code":5000,"success":"true", "message":"Warp App Started Successfully"}'
			else
				echo '{"success":"false","code":9102, "message":"Warp App Could Not Be Started"}'
                        fi
		fi
;;

# webserver stop case
stop)
		ud=`netstat -npl|grep udp |grep 12346|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                if [ -z "$ud" ]; then
                        echo '{"code":5000,"success":"true", "message":"Warp App already Stopped"}'
                else
			crontab -r
                        warpstop
			sleep 15
			ud1=`netstat -npl|grep udp |grep 12346|cut -d'/' -f1|rev|awk '{print $1}'|rev`
			if [ -z "$ud1" ]; then
				echo '{"code":5000,"success":"true", "message":"Warp App Stopped Successfully"}'
                        else
				echo '{"success":"false","code":9103, "message":"Warp App Could Not Be Stopped"}'
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
#               wget --no-check-certificate --directory-prefix=$HOME/download $2

                if [ $? -eq 0 ]; then
                        rm -rf $HOME/.aws/config $HOME/url
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
			
			ant compile -f  $HOME/download/$d/warp.xml > $HOME/Logs/compile.out 2>&1
			compile=`grep "BUILD SUCCESSFUL" $HOME/Logs/compile.out`
			
			echo "Compilation Result = $compile"
			if [ "$compile" = "BUILD SUCCESSFUL" ]; then
				ud=`netstat -npl|grep udp |grep 12346|cut -d'/' -f1|rev|awk '{print $1}'|rev`
				echo "udp=$ud"
                		if [ -n "$ud" ]; then
					warpstop
				else
		                        echo "Warp App Already Started"
				fi
                               	if [ $? -eq 0 ]; then
					mkdir -p $HOME/backup/DB_Files/
					grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d"/" -f2-100|rev|cut -d'"' -f2-100 > $HOME/old_db_p
			                Old_DBFile_Name=`grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d'"' -f2|cut -d"/" -f1|rev`
			                Old_DBFile_Path=`grep -v "$Old_DBFile_Name" $HOME/old_db_p`
			                cp -arf $HOME/app/appwarp/$Old_DBFile_Path/$Old_DBFile_Name* $HOME/backup/DB_Files/
                                	# backup existing application
                                	if [ -d $HOME/app/appwarp ]; then
                                		mv $HOME/app/appwarp $HOME/backup/.
                        		else
                                		echo "dir not found"
                        		fi
                                	if [ $? -eq 0 ]; then 
                                        # move source to php folder
                                        if [ -d $HOME/download/$d ]; then
					        mv $HOME/download/$d $HOME/app/appwarp
                                        else
                                                mkdir -p $HOME/app/appwarp/
                                                mv $HOME/download/$d $HOME/app/appwarp/warp.xml
                                        fi
						if [ $? -eq 0 ]; then
                                                	#echo '{"code":5000,"success":"true", "message":"App extracted and moved"}'
							grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d"/" -f2-100|rev|cut -d'"' -f2-100 > $HOME/new_db_p
					                New_DBFile_Name=`grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d'"' -f2|cut -d"/" -f1|rev`
			        		        New_DBFile_Path=`grep -v "$New_DBFile_Name" $HOME/new_db_p`
					
		                                        echo "Old_DBFiles_Path = $Old_DBFile_Path"
                		                        echo "Old_DBFile_Name = $Old_DBFile_Name"
                                		        echo "New_DBFiles_Path = $New_DBFile_Path"
		                                        echo "New_DBFile_Name = $New_DBFile_Name"
							if [ -n "$Old_DBFile_Path" ]; then
								rm -rf $HOME/app/appwarp/$Old_DBFile_Path
		                                        fi
							if [ -n "$New_DBFile_Path" ]; then	
								mkdir -p $HOME/app/appwarp/$New_DBFile_Path
                                                		cp -arf $HOME/backup/DB_Files/$Old_DBFile_Name* $HOME/app/appwarp/$New_DBFile_Path
							else
                		                                cp -arf $HOME/backup/DB_Files/$Old_DBFile_Name* $HOME/app/appwarp/
							fi

							rm -rf $HOME/app/appwarp/Logs
                                               		ln -sf $HOME/Logs $HOME/app/appwarp/Logs
	                                                warpstart
							sleep 20
							ud=`netstat -npl|grep udp |grep 12346|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                        			        echo "udp=$ud"
			                                if [ -n "$ud" ]; then
                	                                        # remove downloaded and backup file
                        	                                rm -rf $HOME/download
                                	                        rm -rf $HOME/backup/appwarp*
                                        	                echo '{"code":5000,"success":"true", "message":"Warp App Deployed Successfully"}'


#############################################
                                        ######### ------------######################
                                                	else
								warpstop
                                                                sleep 10
								warpstart
                                                        	sleep 20
                                                	        ud=`netstat -npl|grep udp |grep 12346|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                                        	                echo "udp=$ud"
                                	                        if [ -n "$ud" ]; then
                        	                                        # remove downloaded and backup file
                	                                                rm -rf $HOME/download
        	                                                        rm -rf $HOME/backup/appwarp*
	                                                                echo '{"code":5000,"success":"true", "message":"Warp App Deployed Successfully"}'
								else
									rm -rf $HOME/app/appwarp
                                                		        mv $HOME/backup/appwarp $HOME/app/appwarp
                                		                        ln -sf $HOME/Logs $HOME/app/appwarp/Logs
                		                                        if [ -n "$New_DBFile_Path" ]; then
		                                                                mkdir -p $HOME/app/appwarp/$New_DBFile_Path
                                                                		cp -arf $HOME/backup/DB_Files/$Old_DBFile_Name* $HOME/app/appwarp/$New_DBFile_Path
                                                		        fi
									warpstop
	                                                                sleep 10
                                		                        warpstart
                		                                        rm -rf $HOME/backup/appwarp*
		                                                        rm -rf $HOME/download
									echo '{"success":"false","code":9104, "message":"New Warp App Could Not Be Started, Deployment Failed"}'
        	                                                	exit 1
								fi
                                                	fi

						else
                                                	# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
	                                                rm -rf $HOME/app/appwarp
        	                                        mv $HOME/backup/appwarp $HOME/app/appwarp
							ln -sf $HOME/Logs $HOME/app/appwarp/Logs
							if [ -n "$New_DBFile_Path" ]; then
                                          			mkdir -p $HOME/app/appwarp/$New_DBFile_Path
								cp -arf $HOME/backup/DB_Files/$Old_DBFile_Name* $HOME/app/appwarp/$New_DBFile_Path
                                		        fi
                        	                        warpstart
							rm -rf $HOME/backup/appwarp*
                                        	        rm -rf $HOME/download
                                                	echo '{"success":"false","code":9105, "message":"Warp App Deployment Failed"}'
	                                                exit 1
        	                                fi
                                                                                
					else
                        	                warpstart
                                	        # remove downloaded file
                                        	rm -rf $HOME/download
	                                        echo '{"success":"false","code":9106, "message":"Warp App Contents For Backup Could Not Be Moved"}'
        	                                exit 1
                	                fi
                                                                
				else
                                	warpstart
	                                # remove downloaded file
        	                        rm -rf $HOME/download
                	                echo '{"success":"false","code":9107, "message":"Warp App Could Not Be Stopped"}'
                        	        exit 1
	                        fi
                                                
			else
                	        # remove downloaded file
                        	rm -rf $HOME/download
	                        echo '{"success":"false","code":9108, "message":"Warp App Compilation Failed"}'
        	                exit 1
                	fi
	else
        	# remove downloaded file
                rm -rf $HOME/download
		rm -rf $HOME/.aws/config $HOME/url
                echo '{"success":"false","code":9109, "message":"Warp App Download Failed"}'
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
                        echo '{"success":"false","code":9110,"message":"PaaSUser SSH key Could Not Be Created"}'
                fi;;

setup)
                wget --no-check-certificate --directory-prefix=$HOME/downloadAdminDashboard https://s3-us-west-2.amazonaws.com/appwarps2/AppWarpAdminDashboard.zip
                if [ $? -eq 0 ]; then
                        unzip $HOME/downloadAdminDashboard/AppWarpAdminDashboard.zip -d $HOME/downloadAdminDashboard/
                        if [ $? -eq 0 ]; then
                                cp -arf $HOME/Logindex $HOME/downloadAdminDashboard/AppWarpAdminDashboard/
                                if [ $? -eq 0 ]; then
                                        mv $HOME/downloadAdminDashboard/AppWarpAdminDashboard/ $HOME/AdminDashboard
                                        if [ $? -eq 0 ]; then
                                                ln -sf $HOME/Logs $HOME/AdminDashboard/$2
                                                if [ $? -eq 0 ]; then
                                                        sudo sed -i 's/'Logs'/'$2'/g' /etc/apache2/sites-available/default
                                                        if [ $? -eq 0 ]; then
                                                                wget --no-check-certificate --directory-prefix=$HOME/downloadChatDemo https://s3-us-west-2.amazonaws.com/appwarps2/ChatDemo.zip
                                                                if [ $? -eq 0 ]; then
                                                                        unzip $HOME/downloadChatDemo/ChatDemo.zip -d $HOME/downloadChatDemo/
                                                                        if [ $? -eq 0 ]; then
                                                                                mv $HOME/downloadChatDemo/ChatDemo/ChatServer $HOME/app/appwarp
                                                                                if [ $? -eq 0 ]; then
                                                                                        sudo /sbin/katr sheppaasuseratr
                                                                                        d=`ls /home/paasadmin/AdminDashboard|grep "$2"`
                                                                                        if [ $d = $2 ]; then
												rm -rf $HOME/app/appwarp/Logs
					                                                        ln -sf $HOME/Logs $HOME/app/appwarp/Logs
                                                                                                sudo /etc/init.d/apache2 restart
                                                                                                warpstart
												crontab -u paasadmin $HOME/cronjob
                                                                                                rm -rf $HOME/downloadAdminDashboard $HOME/downloadChatDemo
                                                                                                echo '{"code":5000,"success":"true","message":"LOG App Rename, Setup is Successfully"}'
                                                                                        else
                                                                                                echo '{"success":"false","code":9111,"message":"LOG App Could Not Be Rename, Setup is Failed"}'
                                                                                                rm -rf $HOME/downloadAdminDashboard $HOME/downloadChatDemo
                                                                                        fi
                                                                                else
                                                                                        echo '{"success":"false","code":9112,"message":"Move AppWarp Demo App to App Dir. Failed"}'
                                                                                        rm -rf $HOME/downloadAdminDashboard $HOME/downloadChatDemo
                                                                                fi
                                                                        else
                                                                                echo '{"success":"false","code":9113,"message":"AppWarp Demo App Unzip Failed"}'
                                                                                rm -rf $HOME/downloadAdminDashboard $HOME/downloadChatDemo
                                                                        fi
                                                                else
                                                                        echo '{"success":"false","code":9114,"message":"AppWarp Demo App download Failed"}'
                                                                        rm -rf $HOME/downloadAdminDashboard $HOME/downloadChatDemo
                                                                fi
                                                        else
                                                                echo '{"success":"false","code":9115,"message":"DeploymentID Entry in Apache Config Failed"}'
                                                                rm -rf $HOME/downloadAdminDashboard
                                                        fi
                                                else
                                                        echo '{"success":"false","code":9116,"message":"Logs Link Regardin DeploymentID Failed"}'
                                                        rm -rf $HOME/downloadAdminDashboard
                                                fi
                                        else
                                                echo '{"success":"false","code":9117,"message":"Move AdminDashboard to HOME Failed"}'
                                                rm -rf $HOME/downloadAdminDashboard
                                        fi
                                else
                                        echo '{"success":"false","code":9118,"message":"Copy Logindex in AdminDashboard Failed"}'
                                        rm -rf $HOME/downloadAdminDashboard
                                fi
                        else
                                echo '{"success":"false","code":9119,"message":"AdminDashboard Unzip Failed"}'
                                rm -rf $HOME/downloadAdminDashboard
                        fi
                else
                        echo '{"success":"false","code":9120,"message":"AdminDashboard download Failed"}'
                        rm -rf $HOME/downloadAdminDashboard
                fi;;


                               
usages)
		mem=`free -m |grep "Mem"|awk '{print $3}'`
		cpu=`top -bn1 |grep "Cpu"|awk '{print $2}'|cut -d"%" -f1`
		echo '{"code":5000,"success":"true","message":"Current Resorce Usages In '$containername'","memory":"'$mem'","cpu":"'$cpu'"}'
		;;

backup)
                rm -rf $HOME/DB_Backup
                mkdir -p $HOME/DB_Backup/DB/
		grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d"/" -f2-100|rev|cut -d'"' -f2-100 > $HOME/old_db_p
                Old_DBFile_Name=`grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d'"' -f2|cut -d"/" -f1|rev`
                Old_DBFile_Path=`grep -v "$Old_DBFile_Name" $HOME/old_db_p`
		cp -arf $HOME/app/appwarp/$Old_DBFile_Path/$Old_DBFile_Name* $HOME/DB_Backup/DB/
                echo "cp -arf $HOME/app/appwarp/$Old_DBFile_Path/$Old_DBFile_Name* $HOME/DB_Backup/DB/"
                cd $HOME/DB_Backup && tar czf DB.tar.gz DB
                if [ $? -eq 0 ]; then
			rm -rf $HOME/DB_Backup/DB/
                        echo '{"code":5000,"success":"true","message":"DB_Files Backup Created","appBackupPath":"'$HOME/DB_Backup/DB.tar.gz'"}'
                else
			rm -rf $HOME/DB_Backup/
                        echo '{"success":"false","code":9121,"message":"DB_Files Backup Could Not Be Created"}'
                fi;;

restore)
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
#                wget --no-check-certificate --directory-prefix=$HOME/download $2
                fileWithExt=${2##*/}
                echo "file=$fileWithExt"
                tar xzf $HOME/download/$fileWithExt -C $HOME/download/
                grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d"/" -f2-100|rev|cut -d'"' -f2-100 > $HOME/new_db_p
                New_DBFile_Name=`grep "HSQLDBFile" $HOME/app/appwarp/AppConfig.json |awk '{ print $3}'|rev|cut -d'"' -f2|cut -d"/" -f1|rev`
                New_DBFile_Path=`grep -v "$New_DBFile_Name" $HOME/new_db_p`
                warpstop
                if [ -n "$New_DBFile_Path" ]; then
                        cp -arf $HOME/download/DB/* $HOME/app/appwarp/$New_DBFile_Path/
                        echo "cp -arf $HOME/download/DB/* $HOME/app/appwarp/$New_DBFile_Path/"
                else
                        cp -arf $HOME/download/DB/* $HOME/app/appwarp/
                        echo "cp -arf $HOME/download/DB/* $HOME/app/appwarp/"
                fi
                if [ $? -eq 0 ]; then
                        warpstart
                        rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"code":5000,"success":"true","message":"DB Restored Successfully"}'
                else
                        warpstart
                        rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":9122,"message":"DB Restore Failed"}'
                fi;;


update)
                rm -rf $HOME/AdminDashboard.old
                wget --no-check-certificate --directory-prefix=$HOME/downloadAdminDashboard https://s3-us-west-2.amazonaws.com/appwarps2/AppWarpAdminDashboard.zip
		if [ $? -eq 0 ]; then
	                unzip $HOME/downloadAdminDashboard/AppWarpAdminDashboard.zip -d $HOME/downloadAdminDashboard/
			if [ $? -eq 0 ]; then
		                cp -arf $HOME/Logindex $HOME/downloadAdminDashboard/AppWarpAdminDashboard/
				if [ $? -eq 0 ]; then
			                mv $HOME/AdminDashboard $HOME/AdminDashboard.old
					if [ $? -eq 0 ]; then
				                mv $HOME/downloadAdminDashboard/AppWarpAdminDashboard/ $HOME/AdminDashboard
						if [ $? -eq 0 ]; then
					                ln -sf $HOME/Logs $HOME/AdminDashboard/$2
					                d=`ls /home/paasadmin/AdminDashboard|grep "$2"`
					                if [ $d = $2 ]; then
					                        sudo /etc/init.d/apache2 restart
					                        rm -rf $HOME/downloadAdminDashboard
					                        echo '{"code":5000,"success":"true","message":"AdminDashboard Updated Successfully"}'
							else
					                        echo '{"success":"false","code":9123,"message":"AdminDashboard Could Not Be Update"}'
					                        rm -rf $HOME/AdminDashboard
					                        mv $HOME/AdminDashboard.old $HOME/AdminDashboard
					                        rm -rf $HOME/downloadAdminDashboard
					                fi
						else
	                                                echo '{"success":"false","code":9124,"message":"Move AdminDashboard to HOME Failed"}'
							mv $HOME/AdminDashboard.old $HOME/AdminDashboard
                                                	rm -rf $HOME/downloadAdminDashboard
                                        	fi
					else
	                                        echo '{"success":"false","code":9125,"message":"Backup Old AdminDashboard Failed"}'
						mv $HOME/AdminDashboard.old $HOME/AdminDashboard
                                        	rm -rf $HOME/downloadAdminDashboard
                                	fi
				else
	                                echo '{"success":"false","code":9126,"message":"Copy Logindex in AdminDashboard Failed"}'
                                	rm -rf $HOME/downloadAdminDashboard
                        	fi
			else
	                        echo '{"success":"false","code":9127,"message":"AdminDashboard Unzip Failed"}'
                        	rm -rf $HOME/downloadAdminDashboard
                	fi
		else
                        echo '{"success":"false","code":9128,"message":"AdminDashboard download Failed"}'
                        rm -rf $HOME/downloadAdminDashboard
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

reset_htpasswd)
                htpasswd -bc $HOME/htpasswd $2 $3
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Http Auth Reset Successfully"}'
                else
                        echo '{"success":"false","code":9313,"message":"Http Auth Not Be Reset"}'
                fi;;


esac
