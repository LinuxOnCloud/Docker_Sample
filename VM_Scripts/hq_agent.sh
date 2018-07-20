#!/bin/bash

tomcat=`cat /opt/tomcat-detail 2> /dev/null`


export JAVA_HOME="/opt/java6"
export GRAILS_HOME="/opt/grails-1.3.3"
export PATH=$PATH:$GRAILS_HOME/bin:$JAVA_HOME/bin


# start tomcat function
tomcatstart() {
        cd /opt/tomcat/webapps && sudo /etc/init.d/tomcat start
}

# stop tomcat function
tomcatstop() {
        sudo /etc/init.d/tomcat stop
	pid=`sudo ps aux |grep java|grep tomcat| awk '{print $2}'`
        sudo kill -9 $pid
	sudo /root/atr_set
}


case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 			${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":6301,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
		state=`sudo ps aux |grep java|grep tomcat| awk '{print $2}'`     	
		if [ -n "$state" ]; then  		
			echo '{"code":5000,"success":"true", "message":"Tomcat Already Started"}'
          	else
			tomcatstart 
			if [ $? -eq 0 ]; then
				echo '{"code":5000,"success":"true", "message":"Tomcat Started Successfully"}'
			else
				echo '{"success":"false", "code":6302,"message":"Tomcat Could Not Be Started"}'
			fi
		fi;;

# webserver stop case
stop)
		stat=`sudo ps aux |grep java|grep tomcat| awk '{print $2}'`
   		if [ -z "$stat" ]; then
			echo '{"code":5000,"success":"true", "message":"Tomcat already Stopped"}'
		else
			tomcatstop
			if [ $? -eq 0 ]; then
            			echo '{"code":5000,"success":"true", "message":"Tomcat Stopped Successfully"}'
          		else
          			echo '{"success":"false","code":6303, "message":"Tomcat Could Not Be Stopped"}'
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
			tomcatstop               	 
			
			if [ $? -eq 0 ]; then
				# backup existing application
				mkdir -p $HOME/backup/
				if [ -d /opt/tomcat/webapps/ROOT ]; then
					mv /opt/tomcat/webapps/ROOT* $HOME/backup/.
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
                        if [ "$FileExt" = "tar.gz" ] || [ "$FileExt" = "war.tar.gz" ] || [ "$FileExt" -eq "tar.gz" ] || [ "$FileExt" -eq "war.tar.gz" ]; then
							echo "file tar.gz or war.tar.gz ext true = $FileExt"
                        else
							f=`echo $FileExt | cut -d'.' -f2`
                            FileExt=$f
                            echo "file tar.gz or war.tar.gz ext false = $FileExt"
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
					rm -rf /opt/tomcat/work/*
                                        rm -rf /opt/tomcat/temp/*
					mv $HOME/download/$d /opt/tomcat/webapps/ROOT.war
							
					if [ $? -eq 0 ]; then
						tomcatstart
										
						if [ $? -eq 0 ]; then
							# remove downloaded and backup file
							rm -rf $HOME/backup/ROOT*	
							rm -rf $HOME/download	
							echo '{"code":5000,"success":"true", "message":"HQ App Deployed Successfully"}'
										

#############################################
					######### ------------######################
						else
							echo '{"success":"false", "code":6304,"message":"HQ App Deployed But Tomcat Could Not Be Started"}' 
							exit 1							
                                        	fi

					
					else
						# remove apps contents, coping app data from backup, start webserver & remove downloaded and backup file
						rm -rf /opt/tomcat/webapps/ROOT*
						mv $HOME/backup/ROOT* /opt/tomcat/webapps/.
						tomcatstart
#						sudo rm -rf $HOME/download
						rm -rf $HOME/backup/ROOT*
						echo '{"success":"false","code":6305,"message":"HQ App Deployment Failed"}'
						exit 1
					fi 

				else
					tomcatstart
					# remove downloaded file
                                	rm -rf $HOME/download
					echo '{"success":"false", "code":6306,"message":"HQ App Contents For Backup Could Not Be Moved"}'						
					exit 1
				fi
			else
				tomcatstart
				# remove downloaded file
	                	rm -rf $HOME/download
				echo '{"success":"false","code":6307, "message":"Tomcat Could Not Be Stopped"}'
	       	        	exit 1
			fi
		else
			# remove downloaded file
			rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
			echo '{"success":"false", "code":6308,"message":"HQ App Download Failed"}'
			exit 1
		fi;;


create_war)

	sudo /etc/init.d/tomcat stop
        cd $HOME/app/AppHQ/ && git pull
        if [ $? = 0 ]; then
                #/bin/bash $HOME/config_constructor.sh $2 $3 $4 $5 $6 $7 $8
                #/bin/bash $HOME/datasource_constructor.sh $9 ${10} ${11}
                /$HOME/config_constructor $2 $3 $4 $5 $6 $9 ${13} ${14} ${15}
                /$HOME/datasource_constructor ${10} ${11} ${12}
                if [ $? = 0 ]; then
                        #cd $HOME/app/AppHQ/ && grails clean
                        cd $HOME/app/AppHQ/ && grails war ROOT.war
                        if [ $? = 0 ]; then
                                mkdir -p $HOME/Warfile
				mv $HOME/app/AppHQ/ROOT.war $HOME/Warfile/ROOT.war
				#rm -rf $HOME/.grails/
                                rm -rf $HOME/.ivy2/
				tomcatstart
                                echo '{"code":5000,"success":"true","message":"HQ WAR File Created Successfully","path":"'$HOME/Warfile/ROOT.war'"}'
                        else
                                rm -rf $HOME/app/AppHQ/ROOT.war
                                rm -rf $HOME/Warfile/ROOT.war
                                echo '{"success":"false","code":6309,"message":"HQ WAR File Creation Failed"}'
                        fi

                else
                        rm -rf $HOME/app/AppHQ/ROOT.war
                        rm -rf $HOME/Warfile/ROOT.war
			echo '{"success":"false","code":6310,"message":"HQ Service Parameters Could Not Be Changed"}'
                fi
        else
                rm -rf $HOME/app/AppHQ/ROOT.war
                rm -rf $HOME/Warfile/ROOT.war
                echo '{"success":"false","code":6311,"message":"HQ Git Pull Could Not Be Successfull"}'
        fi;;

delete_war)

	if [ -d $HOME/Warfile ]; then
	rm -rf $HOME/Warfile
		echo '{"code":5000,"success":"true","message":"HQ WAR File Deleted Successfully"}'
	else
		echo '{"success":"false","code":6312,"message":"HQ WAR File Could Not Be Deleted"}'
	fi;;
		
		
*)
	echo 'Usage: {cmd|start|stop|deploy|create_war|delete_war}'
	echo '{"success":"false", "code":6313,"message":"Invalid Command"}'
       	;;
esac
