#!/bin/bash

host=`hostname`
dt=`date +%d%b%Y`
redispass=`grep 'requirepass' /etc/redis/redis.conf|tail -1|awk '{print $2}'`

# start redis
redisstart() {
        sudo /etc/init.d/redis-server start 
}

# stop redis
redisstop() {
        sudo /etc/init.d/redis-server stop
}

# restart redis
redisrestart() {
        sudo /etc/init.d/redis-server restart
}

case $1 in

cmd)
                $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}                 ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Command Successfully Executed"}'
                else
                        echo '{"success":"false","code":5501,"message":"Command Execution Failed"}'
                fi;;

start)
                state=`ps aux |grep redis-server|grep usr|awk '{print $2}'`
                if [ -n "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"Redis Already Started"}'
                else
                        redisstart
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true","message":"Redis Started Successfully"}'
                        else
                                echo '{"success":"false","code":5502,"message":"Redis Could Not Be Started"}'
                        fi
                fi;;
stop)
                state=`ps aux |grep redis-server|grep usr|awk '{print $2}'`
                if [ -z "$state" ]; then
                        echo '{"code":5000,"success":"true","message":"Redis Already Stopped"}'
                else
			redis-cli -a $redispass bgsave
                        redisstop
			state1=`ps aux |grep redis-server|grep usr|awk '{print $2}'`
                        if [ -z "$state1" ]; then
                                echo '{"code":5000,"success":"true","message":"Redis Stopped Successfully"}'
                        else
                                echo '{"success":"false","code":5503,"message":"Redis Could Not Be Stopped"}'
                        fi
                fi;;

createdb)
		if [ ! -z "$3" ]; then
	                redisstop
        	        sudo sed -i -e 's/requirepass app42_redis_26_password/requirepass '$3'/' /etc/redis/redis.conf
#			redisstop
			sleep 2
			redisstart
			check=`grep requirepass /etc/redis/redis.conf|tail -1|awk '{print $2}'`
	                if [ $check = $3 ]; then
				echo '{"code":5000,"success":"true","message":"Redis Database Password Has Been Set Successfully"}'
			else
				echo '{"success":"false","code":5504,"message":"Redis Database Password Could Not Be Set"}'
			fi
		else
			echo '{"success":"false","code":5505,"message":"Password Could Not Be Set Because Your Password Value Is Blank"}'
         	fi;;


resetpassword)
                sudo sed -i -e 's/requirepass '$3'/requirepass '$4'/' /etc/redis/redis.conf
		redis-cli -a $3 bgsave
		redisstop
                sleep 2
                redisstart
		check=`grep requirepass /etc/redis/redis.conf|tail -1|awk '{print $2}'`
                if [ $check = $4 ]; then
                        echo '{"code":5000,"success":"true","message":"Redis Database Password Reset Successfull"}'
                else
                        echo '{"success":"false","code":5506,"message":"Redis Database Password Could Not Be Reset"}'
                fi;;

backup)
		if [ -f /var/lib/redis/dump.rdb ]; then
			redis-cli -a $2 bgsave
			pwdcheck=`redis-cli -a $2 bgsave|grep 'NOAUTH'|wc -l`
			if [ $pwdcheck = 0 ]; then
				redisstop
				sleep 2
				sudo cp /var/lib/redis/dump.rdb $HOME/dump/dump-$host-$dt.rdb
				sudo chown -R 1001.1001 $HOME/dump
				redisstart
				bkpcheck=`sudo redis-check-dump $HOME/dump/dump-$host-$dt.rdb |tail -1|rev|awk '{print $1}'|rev`
        		        if [ $bkpcheck = OK ]; then
					echo '{"code":5000,"success":"true","message":"Redis Database Backup Created","path":"'$HOME/dump/dump-$host-$dt.rdb'"}'
	                	else
					echo '{"success":"false","code":5507,"message":"Redis Database Backup Could Not Be Created"}'
	                	fi
			else
				echo '{"success":"false","code":5508,"message":"Redis Database Password Incorrect"}'
			fi
		else
			echo '{"success":"false","code":5509,"message":"Redis Database Dump is Not Available"}'
		fi;;

restore)

                # download source/binary
                wget --no-check-certificate --directory-prefix=$HOME/download $4

                if [ $? -eq 0 ]; then
			rm -rf $HOME/.aws/config $HOME/url
                        #echo '{"code":5000,"success":"true","message":"File Download successfully"}'
                        #mv $HOME/backup/$4.sql $HOME/backup/$4.sql-`date +%d%b%Y`
			redis-cli -a $2 bgsave
			redisstop
	                sleep 2
        	        sudo cp /var/lib/redis/dump.rdb $HOME/backup/dump.rdb
			sudo chown -R 1001.1001 $HOME/backup
			bkpcheck=`redis-check-dump $HOME/backup/dump.rdb|tail -1|rev|awk '{print $1}'|rev`
                        if [ $bkpcheck = OK ]; then
                                #echo '{"code":5000,"success":"true","message":"Create current db backup"}'
                                # extract file extenstion and file name from URL
				redisstart
                                fileWithExt=${4##*/}
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

                                        rdb.tar.gz)
                                                tar xvzf $HOME/download/$fileWithExt -C $HOME/download/ > $HOME/result
                                                d=`head -1 $HOME/result`
                                                out=$d
                                                echo out=$out;;

                                        gz)
                                         	gunzip -v $HOME/download/$fileWithExt 2> $HOME/result
                                                d=`cat $HOME/result |rev|cut -d'/' -f1|rev`
				                out=$d
                                                echo out=$out;;

                                        rdb.gz)
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
                                
                                        rdb.zip)
                                                unzip $HOME/download/$fileWithExt -d $HOME/download/ >$HOME/result
                                                d=`tail -1 $HOME/result | rev|cut -d'/' -f1|rev`
                                                d=`echo $d | tr -d ' '`
                                                out=$d
                                                echo out=$out;;
                                  	rdb)
                                                out=$fileWithExt
                                                echo out=$out;;

                                esac
                                # move source to redis folder
				dwnfcheck=`redis-check-dump $HOME/download/$out|tail -1|rev|awk '{print $1}'|rev`

                                if [ $dwnfcheck = OK ]; then
					redisstop
					sudo rm /var/lib/redis/dump.rdb
					cp $HOME/download/$out /var/lib/redis/dump.rdb
					sudo chown -R 103.1001 /var/lib/redis/dump.rdb
echo "permission done"
					redisstart					
                                        rm -rf $HOME/download
                                        rm -rf $HOME/backup/dump.rdb
                         echo '{"code":5000,"success":"true","message":"Redis Database Restored Successfully"}'


#############################################
                                        ######### ------------######################
                                else
					redisstop
                                        sudo rm /var/lib/redis/dump.rdb
                                        cp $HOME/backup/dump.rdb /var/lib/redis/dump.rdb
					sudo chown -R 103.1001 /var/lib/redis/dump.rdb
                                        redisstart
                                        rm -rf $HOME/download
                                        rm -rf $HOME/backup/dump.rdb
                                        echo '{"success":"false","code":5510,"message":"Redis Database Restore Failed"}'
                                        exit 1
                                  fi

                        else
                                # remove contents of www folder and downloaded file
                                rm -rf $HOME/download
                                rm -rf $HOME/backup/dump.rdb
				redisstart
                                echo '{"success":"false","code":5511,"message":"Redis Current Database Backup Failed"}'
                                exit 1
                        fi
                                                                                
                else
                        rm -rf $HOME/download
			rm -rf $HOME/.aws/config $HOME/url
                        echo '{"success":"false","code":5512,"message":"Redis Error In Downloading Backup File"}'
                        exit 1
                      fi
                                                                
                ;;

restart)
		redis-cli -a $redispass bgsave
                redisstop
		sleep 2
		redisstart
                if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true","message":"Redis Restarted Successfully"}'
                else
			echo '{"success":"false","code":5513,"message":"Redis Could Not Be Restarted"}'
                fi;;
        
        
delete_backup)
                if [ -f $2 ]; then
			rm -rf $2
                        echo '{"code":5000,"success":"true","message":"Redis Backup Deleted Successfully"}'
                else
			echo '{"success":"false","code":5514,"message":"Redis Backup Deletion Failed"}'
                fi;;
                
*)
                echo 'Usage: {cmd|start|stop|createdb|resetpassword|backup|restore|restart|delete_backup}'
                echo '{"success":"false", "code":5515,"message":"Invalid Command"}'
                ;;
		
esac

