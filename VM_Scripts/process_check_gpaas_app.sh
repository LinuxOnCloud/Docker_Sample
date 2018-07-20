

dns=`ec2metadata --public-hostname`
EMAIL="abc@example.com"


#d=`sudo netstat -npl|grep $1|grep 80|awk '{print $7}'|cut -d"/" -f1`

d=`sudo netstat -npl|grep $1|grep $2|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
uptime=`cat /proc/uptime|cut -d'.' -f1`
chk_uptime="360"

/bin/echo "d=$d"

if [ -z $d ]; then
	if [ $chk_uptime -le $uptime ]; then
		echo "Down mail send"
		echo "`date`:Production GPaaS Server Process $1 is Down, Host $dns Service $1 is Down!" | mail -s "Host $dns Service $1 Is DOWN!" $EMAIL
	fi
	/bin/echo "Process $1 Is Currently Stopped, Now Script Is Starting $1 Process In Progess"
	$3 stop && $3  start
	/bin/echo "Process $1 Is Started"
	sleep 10
	if [ $chk_uptime -le $uptime ]; then
		echo "Up mail send"
		echo -e "`date`:Production GPaaS Server Process $1 is Up, Host $dns Service $1 is Up!" | mail -s "Host $dns Service $1 is UP!" $EMAIL
	fi
else
	/bin/echo "Process $1 Is Running"

fi
