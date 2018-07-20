#!/bin/bash
# start couchdb
couchdbstart() {
	sudo /etc/init.d/couchdb start
}
# stop couchdb
couchdbstop() {
        sudo /etc/init.d/couchdb stop
}
# restart couchdb
couchdbrestart() {
        sudo /etc/init.d/couchdb restart
}
# reload couchdb
couchdbreload() {
        sudo /etc/init.d/couchdb force-reload
}




case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Command Successfully Executed"}'
                else
			echo '{"success":"false","code":5101,"message":"Command Execution Failed"}'
                fi;;

start)
		state=`ps aux |grep couchdb|grep usr|awk '{print $2}'`
                if [ -n "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"CouchDB Already Started"}'
                else
                        couchdbstart
                        if [ $? -eq 0 ]; then
                            echo '{"code":5000,"success":"true","message":"CouchDB Started Successfully"}'
                        else
                                echo '{"success":"false","code":5102,"message":"CouchDB Could Not Be Started"}'
                        fi
                fi;;

stop)
		state=`ps aux |grep couchdb|grep usr|awk '{print $2}'`
                if [ -z "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"CouchDB Already Stopped"}'
                else
                        couchdbstop
                        if [ $? -eq 0 ]; then
                            echo '{"code":5000,"success":"true","message":"CouchDB Stopped Successfully"}'
                        else
                                echo '{"success":"false","code":5103,"message":"CouchDB Could Not Be Stopped"}'
                        fi
                fi;;



createdb)
#		SALT=`openssl rand 16 | openssl md5|awk '{print $2}'`
#		PASSWORD_SHA=`echo -n "$4$SALT"| openssl sha1 |awk '{print $2}'`
#		curl -X PUT http://localhost:5984/_users/org.couchdb.user:$3 -d '{"name":"'$3'", "salt":"'$SALT'", "password_sha":"'$PASSWORD_SHA'", "roles":[], "type":"user"}' -H "Content-Type: application/json" > $HOME/123
#		q=`cat $HOME/123 |cut -d':' -f1|cut -d'"' -f2`
#		if [ $q = ok ]; then
			sudo echo ";$3 = $4" >> /etc/couchdb/local.ini
			sudo echo "$3 = $4" >> /etc/couchdb/local.ini
			sleep 2
			couchdbreload
			sleep 2
			curl -X PUT http://$3:$4@localhost:5984/$2 >$HOME/123
	                q=`cat $HOME/123 |cut -d':' -f1|cut -d'"' -f2`
        	        if [ $q = ok ]; then
                	        echo '{"code":5000,"success":"true","message":"CouchDB Database Created and User Added Successfully"}'
	                else
        	                echo '{"success":"false","code":5104,"message":"CouchDB Database And User Could Not Be Created"}'
                	fi;;


resetpassword)
#		rev=`curl  -X GET http://admin:app42_couch_db_101_password@0.0.0.0:5984/_users/org.couchdb.user%3A$3?revs_info=true |cut  -d':' -f4|cut -d '"' -f2`
#		curl  -X DELETE http://admin:app42_couch_db_101_password@0.0.0.0:5984/_users/org.couchdb.user%3A$3?rev=$rev 
#		SALT=`openssl rand 16 | openssl md5|awk '{print $2}'`
#                PASSWORD_SHA=`echo -n "$5$SALT"| openssl sha1 |awk '{print $2}'`
#                curl -X PUT http://localhost:5984/_users/org.couchdb.user:$3 -d '{"name":"'$3'", "salt":"'$SALT'", "password_sha":"'$PASSWORD_SHA'", "roles":[], "type":"user"}' -H "Content-Type: application/json" > $HOME/123
		sudo sed -i '/'$3'/d' /etc/couchdb/local.ini
		sudo echo ";$3 = $5" >> /etc/couchdb/local.ini
                sudo echo "$3 = $5" >> /etc/couchdb/local.ini
		q=`echo $?`
                sleep 2
                couchdbreload
            	sleep 2
		if [ $q = 0 ]; then
                        echo '{"code":5000,"success":"true","message":"CouchDB User Password Reset Successfull"}'
                else
                        echo '{"success":"false","code":5105,"message":"CouchDB User Password Could Not Be Reset"}'
                fi;;

backup)
#		mongodump -d $5 -u $2 -p $3 -o $HOME/backup/dump
		python $HOME/couchdb-python/couchdb/tools/dump.py http://$2:$3@0.0.0.0:5984/$4 > $HOME/dump/$4-`date +%d%b%Y`.dump
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"CouchDB Database Backup Created","path":"'$HOME/dump/$4-`date +%d%b%Y`.dump'"}'
                else
                        echo '{"success":"false","code":5106,"message":"CouchDB Database Backup Could Not Be Created"}'
                fi;;

restore)
		echo $5 > $HOME/url
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
                aws s3 cp s3://$5 $HOME/download/

		# download source/binary
#                wget --no-check-certificate --directory-prefix=$HOME/download $5

                if [ $? -eq 0 ]; then
			rm -rf $HOME/.aws/config $HOME/url
#                       echo '{"code":5000,"success":"true","message":"File Download successfully"}'
			python $HOME/couchdb-python/couchdb/tools/dump.py http://$2:$3@0.0.0.0:5984/$4 > $HOME/backup/$4.dump
			if [ $? -eq 0 ]; then
#                        	echo '{"code":5000,"success":"true","message":"Current database backup successfull"}'
				# extract file extenstion and file name from URL
				fileWithExt=${5##*/}
				echo "file=$fileWithExt"
				FileExt=${fileWithExt#*.}
				d=`echo "$fileWithExt" | cut -d'.' -f1`
				echo "d=$d"
				# extract source
				case $FileExt in
					tar.gz)
                                                tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/result
                                                d=`head -1 $HOME/result`
                                                out=$d
                                                echo out=$out+test;;
                                        dump.tar.gz)
                                                tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/result
                                                d=`head -1 $HOME/result`
                                                out=$d
                                                echo out=$out+test;;

                                        gz)
                                                gunzip -v $HOME/download/$fileWithExt 2> $HOME/result
                                                d=`cat $HOME/result |rev|cut -d'/' -f1|rev`
                                                out=$d
                                                echo out=$out+test;;
                                        dump.gz)
                                                gunzip -v $HOME/download/$fileWithExt 2> $HOME/result
                                                d=`cat $HOME/result |rev|cut -d'/' -f1|rev`
                                                out=$d
                                                echo out=$out+test;;
                                        zip)
                                                unzip $HOME/download/$fileWithExt -d $HOME/download/ >$HOME/result
                                                d=`tail -1 $HOME/result | rev|cut -d'/' -f1|rev`
                                                d=`echo $d | tr -d ' '`
                                                out=$d
                                                echo out=$out+test;;
                                        dump.zip)
                                                unzip $HOME/download/$fileWithExt -d $HOME/download/ >$HOME/result
                                                d=`tail -1 $HOME/result | rev|cut -d'/' -f1|rev`
                                                d=`echo $d | tr -d ' '`
                                                out=$d
                                                echo out=$out+test;;
					dump)
						out=$fileWithExt;;
				esac
				# create db and restore db
				curl -X DELETE http://$2:$3@0.0.0.0:5984/$4
				curl -X PUT http://$2:$3@0.0.0.0:5984/$4
				python $HOME/couchdb-python/couchdb/tools/load.py http://$2:$3@0.0.0.0:5984/$4 < $HOME/download/$out
				if [ $? -eq 0 ]; then
					rm -rf $HOME/download
					rm -rf $HOME/backup/$4.dump
		                     	echo '{"code":5000,"success":"true","message":"CouchDB Database Restored Successfully"}'
					#rm -rf $HOME/$out
					#rm $fileWithExt


#############################################
                                        ######### ------------######################
				else
					curl -X DELETE http://$2:$3@0.0.0.0:5984/$4
	                                curl -X PUT http://$2:$3@0.0.0.0:5984/$4
        	                        python $HOME/couchdb-python/couchdb/tools/load.py http://$2:$3@0.0.0.0:5984/$4 < $HOME/backup/$4.dump
					rm -rf $HOME/download
                                        rm -rf $HOME/backup/$4.dump
                                	echo '{"success":"false","code":5107,"message":"CouchDB Database Restore Failed"}'
					exit 1
                          	fi

			else
				rm -rf $HOME/download
				rm -rf $HOME/backup/$4.dump	
				echo '{"success":"false","code":5108,"message":"CouchDB Current Database Backup Failed"}'
				exit 1
                	fi
										
		else
			rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":5109,"message":"CouchDB Error In Downloading Backup File"}'
                        exit 1
      		fi;;

restart)
       		couchdbrestart
                if [ $? -eq 0 ]; then
                	echo '{"code":5000,"success":"true","message":"CouchDB Restarted Successfully"}'
             	else
                	echo '{"success":"false","code":5110,"message":"CouchDB Could Not Be Restarted"}'
                fi;;

delete_backup)
		if [ -f $2 ]; then
			rm -rf $2
			echo '{"code":5000,"success":"true","message":"CouchDB Backup Deleted Successfully"}'
		else 
			echo '{"success":"false","code":5111,"message":"CouchDB Backup Deletion Failed"}'
		fi;;

*)
                echo 'Usage: {cmd|start|stop|createdb|resetpassword|backup|restore|restart|delete_backup}'
                echo '{"success":"false", "code":5112,"message":"Invalid Command"}'
                ;;			
esac



