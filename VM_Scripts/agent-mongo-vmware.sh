#!/bin/bash

# start mongodb
mongostart() {
	sudo /bin/rm /var/lib/mongodb/mongod.lock
	sudo /etc/init.d/mongodb start
}
# stop mongodb
mongostop() {
        sudo /etc/init.d/mongodb stop
	sudo /bin/rm /var/lib/mongodb/mongod.lock
}
# restart mongodb
mongorestart() {
	sudo /etc/init.d/mongodb restart
}




case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Command Successfully Executed"}'
                else
			echo '{"success":"false","code":5201,"message":"Command Execution Failed"}'
                fi;;

start)
		state=` ps aux |grep mongod|grep usr|awk '{print $2}'`
                if [ -n "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"MongoDB Already Started"}'
                else
                        mongostart
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true","message":"MongoDB Started Successfully"}'
                        else
                                echo '{"success":"false","code":5202,"message":"MongoDB Could Not Be Started"}'
                        fi
                fi;;

stop)
		state=` ps aux |grep mongod|grep usr|awk '{print $2}'`
                if [ -z "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"MongoDB Already Stopped"}'
                else
                        mongostop
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true","message":"MongoDB stopped Successfully"}'
                        else
                                echo '{"success":"false","code":5203,"message":"MongoDB Could Not Be Stopped"}'
                        fi
                fi;;


createdb)
		echo 'db.getSiblingDB("'$2'").addUser( {user: "'$3'", pwd: "'$4'", roles: [ "read", "readWrite", "userAdmin", "dbAdmin" ] } )'|mongo
		echo "db.auth('$3', '$4');"|mongo $2 -u $3 -p $4 >$HOME/123
		c=`cat $HOME/123 |tail -2|head -1`
		echo "Auth=$c"
                if [ "$c" -eq "1" ]; then
                        echo '{"code":5000,"success":"true","message":"MongoDB Database Created and User Added Successfully"}'
                else
                        echo '{"success":"false","code":5204,"message":"MongoDB Database And User Could Not Be Created"}'
		fi;;
		
resetpassword)
		echo "db.changeUserPassword('$3', '$5');" |mongo $2 -u $3 -p $4
                echo "db.auth('$3', '$5');"|mongo $2 -u $3 -p $5 >$HOME/123
                c=`cat $HOME/123 |tail -2|head -1`
		echo "Auth=$c"
                if [ "$c" -eq "1" ]; then
                        echo '{"code":5000,"success":"true","message":"MongoDB User Password Reset successfull"}'
                else
                        echo '{"success":"false","code":5205,"message":"MongoDB User Password Could Not Be Reset"}'
                fi;;


backup)
		mongodump -host localhost --port 27017 --db $4 --username $2 --password $3 --out $HOME/dump/$4-`date +%d%b%Y`
                if [ $? -eq 0 ]; then
			cd $HOME/dump/ && zip -r $4-`date +%d%b%Y`.zip $4-`date +%d%b%Y` && rm -rf $4-`date +%d%b%Y`
                        echo '{"code":5000,"success":"true","message":"MongoDB Database Backup Created","path":"'$HOME/dump/$4-`date +%d%b%Y`.zip'"}'
                else
                        echo '{"success":"false","code":5206,"message":"MongoDB Database Backup Could Not Be Created"}'
			rm -rf $HOME/dump/$4-`date +%d%b%Y`
                fi;;

restore)

		# download source/binary
                wget --no-check-certificate --directory-prefix=$HOME/download $5

                if [ $? -eq 0 ]; then
			rm -rf $HOME/.aws/config $HOME/url
			mongodump -host localhost --port 27017 --db $4 --username $2 --password $3 --out $HOME/backup/$4
			if [ $? -eq 0 ]; then
                        	#echo '{"code":5000,"success":"true","message":"Create current db backup"}'
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
                                                d=`head -1 $HOME/result|cut -d'/' -f1`
                                                out=$d
                                                echo fout=$out+test;;

                                        gz)
                                                gunzip -v $HOME/download/$fileWithExt 2> $HOME/result
                                                d=`cat $HOME/result |rev|cut -d'/' -f1|rev`
                                                out=$d
                                                echo fout=$out+test;;

                                        zip)
                                                unzip $HOME/download/$fileWithExt  -d $HOME/download/ >$HOME/result
                                                d=`cat $HOME/result |grep "creating" |rev|cut -d'/' -f2 |rev|head -1`
                                                out=$d
						rm -rf $HOME/download/$fileWithExt
                                                echo fout=$out+test;;

				esac
				# move source to mongo folder
#				mongorestore -u $2 -p $3  $out
				mongorestore --host localhost --port 27017 --authenticationDatabase $4 --username $2 --password $3 $HOME/download/$out

				# remove downloaded file
				#rm -rf $HOME/$fileWithExt
				if [ $? -eq 0 ]; then
		                     	echo '{"code":5000,"success":"true","message":"MongoDB Database Restored Successfully"}'
					rm -rf $HOME/download
					rm -rf $HOME/backup/$4

#############################################
                                        ######### ------------######################
				else
                                	echo '{"success":"false","code":5207,"message":"MongoDB Database Restore Failed"}'
					mongorestore --host localhost --port 27017 --db $4 --username $2 --password $3 $HOME/backup/$4
					rm -rf $HOME/download
                                        rm -rf $HOME/backup/$4
					exit 1
                          	fi

			else
				
				# remove contents of www folder and downloaded file
                		#rm -rf $HOME/$fileWithExt
                        
				echo '{"success":"false","code":5208,"message":"MongoDB Current Database Backup Failed"}'
				rm -rf $HOME/download
				rm -rf $HOME/backup/$4
				exit 1
                	fi
										
		else
                	#fileWithExt=${2##*/} && echo "filename=$fileWithExt"
			# remove downloaded file
                        #rm -rf $HOME/$fileWithExt
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":5209,"message":"MongoDB Error In Downloading Backup File"}'
			rm -rf $HOME/download
                        exit 1
      		fi
								
		;;
	
restart)
                mongorestart
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"MongoDB Restarted Successfully"}'
                else
                        echo '{"success":"false","code":5210,"message":"MongoDB Could Not Be Restarted"}'
                fi;;

delete_backup)
                if [ -f $2 ]; then
                        rm -rf $2
                        echo '{"code":5000,"success":"true","message":"MongoDB Backup Deleted Successfully"}'
                else
                        echo '{"success":"false","code":5211,"message":"MongoDB Backup Deletion Failed"}'
                fi;;
	
		
*)
		echo 'Usage: {cmd|start|stop|createdb|resetpassword|backup|restore|restart|delete_backup}'
                echo '{"success":"false", "code":5212,"message":"Invalid Command"}'
                ;;
esac
