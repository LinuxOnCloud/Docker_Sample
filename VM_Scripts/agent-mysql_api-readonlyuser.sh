#!/bin/bash

# start mysql
mysqlstart() {
	sudo /etc/init.d/mysql start
}
# stop mysql
mysqlstop() {
        sudo /etc/init.d/mysql stop
}
# restart mysql
mysqlrestart() {
	sudo /etc/init.d/mysql restart
}




case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":5301,"message":"Command Execution Failed"}'
                fi;;


start)
                state=`ps aux |grep mysqld|grep sbin| awk '{print $2}'`
                if [ -n "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"MySql Already Started"}'
                else
                        mysqlstart
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true","message":"MySql Started Successfully"}'
                        else
                                echo '{"success":"false","code":5302,"message":"Mysql Could Not Be Started"}'
                        fi
                fi;;

stop)
                state=`ps aux |grep mysqld|grep sbin| awk '{print $2}'`
                if [ -z "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"MySql Already Stopped"}'
                else
                        mysqlstop
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true","message":"MySql Stopped Successfully"}'
                        else
                                echo '{"success":"false","code":5303,"message":"Mysql Could Not Be Stopped"}'
                        fi
                fi;;

createdb)
		echo "UPDATE mysql.user SET Password=PASSWORD('$7') WHERE User='root'; FLUSH PRIVILEGES;" |mysql -u $5 -p$6
		echo "create database $2;"|mysql -u $5 -p$7
		echo "GRANT SELECT ON $2.* To '$3'@'%' IDENTIFIED BY '$4';"|mysql -u $5 -p$7
		echo "GRANT SELECT ON $2.* To '$3'@'localhost' IDENTIFIED BY '$4';"|mysql -u $5 -p$7
		mysql -u $5 -p$7 $2 < $HOME/pae_web.sql
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"MySql Database Created and User Added Successfully"}'
			rm  $HOME/pae_web.sql
                else
                	echo '{"success":"false","code":5304,"message":"MySql Database And User Could Not Be Created"}'
                fi;;

resetpassword)
		echo "UPDATE mysql.user SET Password=PASSWORD('$5') WHERE User='$3' AND Host='%';FLUSH PRIVILEGES;"|mysql -u $6 -p$7
                echo "UPDATE mysql.user SET Password=PASSWORD('$5') WHERE User='$3' AND Host='localhost';FLUSH PRIVILEGES;"|mysql -u $6 -p$7 
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"MySql User Password Reset Successfull"}'
                else
                	echo '{"success":"false","code":5305,"message":"MySql User Password Could Not Be Reset"}'
                fi;;
		
backup)
		mysqldump -u $2 -p$3 $4 > $HOME/dump/$4-`date +%d%b%Y`.sql
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"MySql Database Backup Created","path":"'$HOME/dump/$4-`date +%d%b%Y`.sql'"}'
                else
                	echo '{"success":"false","code":5306,"message":"MySql Database Backup Could Not Be Created"}'
			rm -rf $HOME/dump/$4.sql*
                fi;;

restore)
		# download source/binary
                wget --no-check-certificate --directory-prefix=$HOME/download $5

                if [ $? -eq 0 ]; then
                        #echo '{"code":5000,"success":"true","message":"File Download successfully"}'
			#mv $HOME/backup/$4.sql $HOME/backup/$4.sql-`date +%d%b%Y`
			mysqldump -u $2 -p$3 $4 > $HOME/backup/$4.sql
			if [ $? -eq 0 ]; then
                        	#echo '{"code":5000,"success":"true","message":"Create current db backup"}'
				# extract file extenstion and file name from URL
				fileWithExt=${5##*/}
				echo "file=$fileWithExt"
				FileExt=${fileWithExt#*.}
				echo "FileExt=$FileExt"
				d=`echo "$fileWithExt" | cut -d'.' -f1`
				echo "d=$d"
				# extract source
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
						unzip $HOME/download/$fileWithExt  -d $HOME/download/ >$HOME/result
                                                d=`tail -1 $HOME/result | rev|cut -d'/' -f1|rev`
						d=`echo $d | tr -d ' '`
                                                out=$d
						echo out=$out;;
				
					sql.zip)
                                                unzip $HOME/download/$fileWithExt  -d $HOME/download/  >$HOME/result
                                                d=`tail -1 $HOME/result | rev|cut -d'/' -f1|rev`
						d=`echo $d | tr -d ' '`
                                                out=$d
                                                echo out=$out;;
                                    	sql)
                                        	out=$fileWithExt
                                        	echo out=$out;;

				esac
				# move source to mysql folder
				echo "drop database $4;"|mysql -u $2 -p$3
				echo "create database $4;"|mysql -u $2 -p$3
				mysql -u $2 -p$3 $4 < $HOME/download/$out

				# remove downloaded file
				if [ $? -eq 0 ]; then
					rm -rf $HOME/download
					rm -rf $HOME/backup/$4.sql
		                     	echo '{"code":5000,"success":"true","message":"Mysql Database Restored Successfully"}'


#############################################
                                        ######### ------------######################
				else
					echo "drop database $4;"|mysql -u $2 -p$3
					echo "create database $4;"|mysql -u $2 -p$3
					mysql -u $2 -p$3 $4 < $HOME/backup/$4.sql
					rm -rf $HOME/download
                                        rm -rf $HOME/backup/$4.sql
					echo '{"success":"false","code":5307,"message":"Mysql Database Restore Failed"}'
					exit 1
                          	fi

			else
				# remove contents of www folder and downloaded file
				rm -rf $HOME/download
				rm -rf $HOME/backup/$4.sql
				echo '{"success":"false","code":5308,"message":"Mysql Current Database Backup Failed"}'
				exit 1
                	fi
										
		else
			rm -rf $HOME/download
			echo '{"success":"false","code":5309,"message":"MySql Error In Downloading Backup File"}'
                        exit 1
      		fi
								
		;;

restart)
                mysqlrestart
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"MySql Restarted Successfully"}'
                else
                        echo '{"success":"false","code":5310,"message":"Mysql Could Not Be Restarted"}'
                fi;;
	
	
delete_backup)
                if [ -f $2 ]; then
                        rm -rf $2
                        echo '{"code":5000,"success":"true","message":"MySql Backup Deleted Successfully"}'
                else
                        echo '{"success":"false","code":5311,"message":"MySql Backup Deletion Failed"}'
		fi;;
		
*)
		echo 'Usage: {cmd|start|stop|createdb|resetpassword|backup|restore|restart|delete_backup}'
                echo '{"success":"false", "code":5312,"message":"Invalid Command"}'
                ;;
esac
