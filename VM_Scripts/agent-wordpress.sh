#!/bin/bash

host=`hostname`

# start apache function
wordpress_start() {
	sudo /etc/init.d/apache2 start
}

# stop apache function
wordpress_stop() {
        sudo /etc/init.d/apache2 stop
#	sudo pkill -kill apache2
}

case $1 in

cmd)		
		$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":6201,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
		state=`sudo ps aux |grep root |grep apache2 |grep usr|awk '{print $2}'`
		if [ -n "$state" ]; then 
                        echo '{"code":5000,"success":"true", "message":"Apache Already Started"}'
		else
			wordpress_start
			if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Apache Started Successfully"}'
	                else
                        echo '{"success":"false","code":6202, "message":"Apache Could Not Be Started"}'
			fi
                fi;;

# webserver stop case
stop)
		state=`sudo ps aux |grep root |grep apache2 |grep usr|awk '{print $2}'`
		if [ -z "$state" ]; then
			echo '{"code":5000,"success":"true", "message":"Apache already Stopped"}'
		else
			wordpress_stop
	                if [ $? -eq 0 ]; then
        	                echo '{"code":5000,"success":"true", "message":"Apache Stopped Successfully"}'
                	else
                	        echo '{"success":"false","code":6203, "message":"Apache Could Not Be Stopped"}'
			fi
                fi;;

configure)
	wordpress_stop
	/$HOME/config_constructor_wordpress $2 $3 $4 $5 $6 > /var/www/wordpress/wp-config.php
        if [ $? = 0 ]; then
                if [ $? = 0 ]; then
			sudo /bin/chmod -R 775 /var/www/ >/dev/null 2>&1
			sudo /bin/chown -R 33.1001 /var/www/ >/dev/null 2>&1
			wordpress_start
                        echo '{"code":5000,"success":"true","message":"WordPress Setup Created Successfully"}'
       		else
			wordpress_start
               		echo '{"success":"false","code":6204,"message":"Log Link Creation Failed"}'
             	fi

    	else
		wordpress_start
 		echo '{"success":"false","code":6205,"message":"WordPress Setup DB Parameters Could Not Be Changed"}'
 	fi;;
		

				
*)
                echo 'Usage: {cmd|start|stop|configure}'
                echo '{"success":"false", "code":6206,"message":"Invalid Command"}'
                ;;
				
esac
