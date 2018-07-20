#!/bin/bash

export JAVA_HOME="/opt/jdk1.7.0_21"
export PATH="$PATH:$JAVA_HOME/bin:/vmpath/sbin"

comp_s=$2
comp_f=$3
pth=/root
comp_pref=App42_PaaS_

# Start Container Manager Function
cmstart() {
        cd $pth/$comp_pref$comp_s && /bin/sh run.sh > $pth/$comp_pref$comp_s/$comp_f-Console.log
}
# Stop Container Manager Function
cmstop() {
        pid=`ps x |grep java|grep $comp_f|awk '{print $1}'`
        kill -9 $pid
}

pidcronadd() {
        echo "*/2     *       *       *       *       /vmpath/sbin/process  $comp_f $pth/$comp_pref$comp_s run.sh > /dev/null 2>&1" >> /root/pidcron
        echo "*/30     *       *       *       *       /vmpath/sbin/process_mail $comp_f >/dev/null 2>&1" >> /root/pidcron
}

pidcronremove() {
        /bin/sed -i '/'$comp_f'/d' /root/pidcron
}

cronadd() {
        crontab -u root /root/pidcron
}
cronremove() {
        crontab -r
}



case $1 in

cmd)
	$2 $3 $4 $5 $6 $7 $8 $9 ${10}
	if [ $? -eq 0 ]; then
		echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
	else
		echo '{"success":"false", "code":6201,"message":"Command Execution Failed"}'
	fi;;

status)

	state=`ps x |grep java|grep $comp_f|awk '{print $1}'`
        echo "state = $state"
	if [ -n "$state" ]; then
                echo '{"message":"'$comp_f' Running"}'
        else
		echo '{"message":"'$comp_f' Stoped"}'
	fi;;

# Container Manager start case
start)
        state=`ps x |grep java|grep $comp_f|awk '{print $1}'`
        echo "state = $state"
        if [ -n "$state" ]; then
                echo '{"message":"Container Manager Already Started"}'
        else
                pidcronremove
                cronremove
                cronadd
                process_cm=`ps x |grep $comp_f|grep process_check.sh|awk '{print $1}'`
                kill -9 $process_cm
                cmstart
                if [ $? -eq 0 ]; then
                        pidcronadd
                        cronadd
                        /vmpath/sbin/process_mail $comp_f
                        echo '{"message":"completed"}'
                else
                        pidcronadd
                        cronadd
                        /vmpath/sbin/process_mail $comp_f
                        echo '{"message":"failed"}'
                fi
        fi;;


stop )
        state=`ps x |grep java|grep $comp_f|awk '{print $1}'`
        echo "state = $state"
        if [ -z "$state" ]; then
                echo '{"message":"Container Manager Already Stoped"}'
        else
                pidcronremove
                cronremove
                cronadd
                process_cm=`ps x |grep $comp_f|grep process_check.sh|awk '{print $1}'`
                kill -9 $process_cm
                cmstop
                if [ $? -eq 0 ]; then
                        echo '{"message":"completed"}'
                else
                        echo '{"message":"failed"}'
                fi
        fi;;

deploy)
	rm -rf /tmp/download-$comp_f
	mkdir -p /tmp/download-$comp_f
	wget --no-check-certificate --directory-prefix=/tmp/download-$comp_f $4
	if [ $? -eq 0 ]; then
		# get download file name
		fileWithExt=${4##*/}
		echo "file=$fileWithExt"
		d=$fileWithExt
		echo "file with ext =$d"
		rm -rf /tmp/backup-$comp_f
		mkdir -p /tmp/backup-$comp_f
		pidcronremove
                cronremove
                cronadd
                process_cm=`ps x |grep $comp_f|grep process_check.sh|awk '{print $1}'`
                kill -9 $process_cm
                cmstop
		mv $pth/$comp_pref$comp_s/$comp_pref$comp_s.jar /tmp/backup-$comp_f/.
		if [ $? -eq 0 ]; then
			mv /tmp/download-$comp_f/$d $pth/$comp_pref$comp_s/$comp_pref$comp_s.jar
			cmstart
			pidcronadd
                        cronadd
                        /vmpath/sbin/process_mail $comp_f
			sleep 30
			state=`ps x |grep java|grep $comp_f|awk '{print $1}'`
		        echo "state = $state"
		        if [ -n "$state" ]; then
				rm -rf /tmp/download-$comp_f
                                rm -rf /tmp/backup-$comp_f
				echo '{"message":"completed"}'
			else
				pidcronremove
		                cronremove
                		cronadd
		                process_cm=`ps x |grep $comp_f|grep process_check.sh|awk '{print $1}'`
                		kill -9 $process_cm
		                cmstop
				rm $pth/$comp_pref$comp_s/$comp_pref$comp_s.jar
				mv /tmp/backup-$comp_f/$comp_pref$comp_s.jar $pth/$comp_pref$comp_s/$comp_pref$comp_s.jar
				cmstart
                	        pidcronadd
        	                cronadd
	                        /vmpath/sbin/process_mail $comp_f
				rm -rf /tmp/download-$comp_f
				rm -rf /tmp/backup-$comp_f
				echo '{"message":"Jar File Can not Run"}'
			fi
		else
			cmstart
                        pidcronadd
                        cronadd
                        /vmpath/sbin/process_mail $comp_f
			rm -rf /tmp/download-$comp_f
                        rm -rf /tmp/backup-$comp_f
			echo '{"message":"Backup Not Create Old Jar File"}'	
		fi
	else
		rm -rf /tmp/download-$comp_f
		echo '{"message":"Jar File Can Not Download For CDN"}'
	fi;;
		
		
esac

