#!/bin/bash

# start postgresql
postgresqlstart() {
	sudo /etc/init.d/postgresql start
}
# stop postgresql
postgresqlstop() {
        sudo /etc/init.d/postgresql stop
}

# stop postgresql
postgresqlreload() {
        sudo /etc/init.d/postgresql reload
}
# restart postgresql
postgresqlrestart() {
	sudo /etc/init.d/postgresql restart
}




case $1 in

cmd)	
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true","message":"Command Successfully Executed"}'
                else
			echo '{"success":"false","code":5401,"message":"Command Execution Failed"}'
                fi;;

start)
                state=`ps aux | grep postgres | grep sbin | awk '{print $2}'`
                if [ -n "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"Postgresql Already Started"}'
                else
                        postgresqlstart
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true","message":"Postgresql Started Successfully"}'
                        else
                                echo '{"success":"false","code":5402,"message":"Postgresql Could Not Be Started"}'
                        fi
                fi;;

stop)
                stat=`ps aux | grep postgres | grep sbin | awk '{print $2}'`
                if [ -z "$stat" ]; then
                        echo '{"code":5000,"success":"true","message":"Postgresql Already Stopped"}'
                else
                        postgresqlstop
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true","message":"Postgresql Stopped Successfully"}'
                        else
                                echo '{"success":"false","code":5403,"message":"Postgresql Could Not Be Stopped"}'
                        fi
                fi;;


createdb)
		# create database
		echo "CREATE DATABASE $2;" |psql -U postgres 2> $HOME/err.psql
		sudo echo "host	$2	$3	0.0.0.0/0	md5" >>	/etc/postgresql/9.1/main/pg_hba.conf
		echo "CREATE USER $3 WITH PASSWORD '$4'; GRANT ALL PRIVILEGES ON DATABASE $2 to $3; alter database $2 owner to $3;" |psql -U postgres 2>> $HOME/err.psql
		#echo "CREATE USER $3 WITH PASSWORD '$4'; GRANT ALL PRIVILEGES ON DATABASE $2 to $3; alter database $2 owner to $3; GRANT postgres TO $3;" |psql -U postgres
		
		if [ -s $HOME/err.psql ]; then
			echo '{"success":"false","code":5404,"message":"Postgresql Database And User Could Not Be Created"}'
                else
			postgresqlreload
			echo '{"code":5000,"success":"true","message":"Postgresql Database Created and User Added Successfully"}'
			rm -rf $HOME/err.psql
                fi;;

resetpassword)
		# create user and grant all privileges on database to user
		echo "ALTER USER $3 WITH PASSWORD '$5';"|psql -d $2 -U postgres 2>  $HOME/errreset.psql 
		if [ -s $HOME/errreset.psql ]; then
			echo '{"success":"false","code":5405,"message":"Postgresql User Password Could Not Be Reset"}'
                else
			echo '{"code":5000,"success":"true","message":"Postgresql User Password Reset Successfull"}'
			rm -rf $HOME/errreset.psql 
		fi;;

backup)
		# backup database
		export PGPASSWORD=$3
		/usr/lib/postgresql/9.1/bin/pg_dump -U $2 $4 > $HOME/dump/$4-`date +%d%b%Y`.sql
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true","message":"Postgresql Database Backup Created","path":"'$HOME/dump/$4-`date +%d%b%Y`.sql'"}'
                else
			echo '{"success":"false","code":5406,"message":"Postgresql Database Backup Could Not Be Created"}'
			rm -rf $HOME/dump/$4-*
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
			#echo '{"code":5000,"success":"true","message":"File Download successfully"}'
			# rename old backup with appropriate date
			#mv $HOME/backup/$2.sql $HOME/backup/$2.sql-`date +%d%b%Y`
			# backup database
			 export PGPASSWORD=$3
			/usr/lib/postgresql/9.1/bin/pg_dump -U $2 $4 > $HOME/backup/$4.sql
			if [ $? -eq 0 ]; then
				#echo '{"code":5000,"success":"true","message":"Create current db backup"}'
				# extract file extension and file name from URL
				fileWithExt=${5##*/}
				echo "file=$fileWithExt"
				FileExt=${fileWithExt#*.}
				echo "FileExt=$FileExt"
				d=`echo "$fileWithExt" | cut -d'.' -f1`
				echo "d=$d"
				# extract dump
				case $FileExt in
				
				tar.gz)
					tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/result
					d=`head -1 $HOME/result`
					out=$d
					echo out=$out;;

				sql.tar.gz)
                                	tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/result
                                        d=`head -1 $HOME/result`
                                        out=$d
                                        echo out=$out;;				

				gz)
					gunzip -v $HOME/download/$fileWithExt 2> $HOME/result
					d=`cat $HOME/result |rev|cut -d'/' -f1|rev`
					out=$d
					echo out=$out;;

				sql.gz)
                                        gunzip -v $HOME/download/$fileWithExt 2> $HOME/result
					d=`cat $HOME/result |rev|cut -d'/' -f1|rev`
                                        out=$d
                                	echo out=$out;;

				zip)	
					unzip $HOME/download/$fileWithExt -d $HOME/download/ >$HOME/result
                                        d=`tail -1 $HOME/result | rev|cut -d'/' -f1|rev`
					d=`echo $d | tr -d ' '`
                                        out=$d
					echo out=$out;;

				sql.zip)
                                        unzip $HOME/download/$fileWithExt -d $HOME/download/ >$HOME/result
                                        d=`tail -1 $HOME/result | rev|cut -d'/' -f1|rev`
					d=`echo $d | tr -d ' '`
                                        out=$d
                              		echo out=$out;;	
				sql)
                                        out=$fileWithExt
                                        echo out=$out;;

				esac
			# retsore database
			echo "DROP DATABASE $4;" |psql -U postgres
			echo "CREATE DATABASE $4; GRANT ALL PRIVILEGES ON DATABASE $4 to $2; alter database $4 owner to $2;" |psql -U postgres
			psql -U $2 $4 < $HOME/download/$out
		
			if [ $? -eq 0 ]; then
				rm -rf $HOME/download
				rm -rf $HOME/backup/$4.sql
				echo '{"code":5000,"success":"true","message":"Postgresql Database Restored Successfully"}'

#############################################
                                        ######### ------------######################
			else
				# force restore
				echo "DROP DATABASE $4;" |psql -U postgres
	                        echo "CREATE DATABASE $4; GRANT ALL PRIVILEGES ON DATABASE $4 to $2; alter database $4 owner to $2;" |psql -U postgres
				psql -U $2 $4 <  $HOME/backup/$4.sql 
				rm -rf $HOME/download
				rm -rf $HOME/backup/$4.sql
					echo '{"success":"false","code":5407,"message":"Postgresql Database Restore Failed"}'
				exit 1
                        fi

		else

                  # remove downloaded file
			rm -rf $HOME/download
			rm -rf $HOME/backup/$4.sql
		  	echo '{"success":"false","code":5408,"message":"Postgresql Current Database Backup Failed"}'
		  	exit 1
          	fi
	else
	     	# remove downloaded file
		rm -rf $HOME/download
		rm -rf $HOME/.aws/config $HOME/url
		echo '{"success":"false","code":5409,"message":"Postgresql Error In Downloading Backup File"}'
		exit 1
       fi;;

restart)
                postgresqlrestart
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Postgresql Restarted Successfully"}'
                else
                        echo '{"success":"false","code":5410,"message":"Postgresql Could Not Be Restarted"}'
                fi;;

delete_backup)
                if [ -f $2 ]; then
                        rm -rf $2
                        echo '{"code":5000,"success":"true","message":"Postgresql Backup Deleted Successfully"}'
                else
                        echo '{"success":"false","code":5411,"message":"Postgresql Backup Deletion Failed"}'
                fi;;
	   
	   
*)
		echo 'Usage: {cmd|start|stop|createdb|resetpassword|backup|restore|restart|delete_backup}'
                echo '{"success":"false", "code":5412,"message":"Invalid Command"}'
                ;;

esac
