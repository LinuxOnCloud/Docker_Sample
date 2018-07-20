#!/bin/bash
LOG=/opt/process-data/stat/stat

Outfile=/opt/process-data/process_out/log

#EMAIL="abc@example.com"
EMAIL="abc@example.com"

if [ ! -d /opt/process-data/stat ]; then
        mkdir -p /opt/process-data/stat
fi

if [ ! -d /opt/process-data/process_out ]; then
        mkdir -p /opt/process-data/process_out
fi


for i in $@; do
        echo "$i-PROCESS-UP!" > $LOG-$i

done

while true; do
        for i in $@; do

date >> $Outfile.$i

#stat=`nmap -p$1 $i |grep tcp|awk '{ print $2 }'`
#servicename=`nmap -p$1 $i |grep tcp|awk '{ print $3 }'`
#dns=`nmap -p$1 $i |grep report|awk '{ print $5 }'`

process=`ps x |/bin/grep java|/bin/grep $1 |/usr/bin/awk '{print $1}'`
ip=`ip \r |grep eth0|tail -1|rev|awk '{ print $1}'|rev`
dns=`dig -x $ip|grep PTR|tail -1|rev|awk '{ print $1 }'|rev`

ps aux |/bin/grep java|/bin/grep $1 >> $Outfile.$i

if [ -z $process ]; then
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-PROCESS-DOWN!" ]; then
                        echo "`date`: Process $1 is Down, Host $dns Service $1 is Down!" | mail -s "Host $dns Service $1 Is DOWN!" $EMAIL

                fi
        echo "$i-PROCESS-DOWN!" > $LOG-$i
	sleep 30

else
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-PROCESS-UP!" ]; then
                        echo -e "`date`: Process $1 is Up, Host $dns Service $1 is Up!" | mail -s "Host $dns Service $1 is UP!" $EMAIL && mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
                fi
        echo "$i-PROCESS-UP!" > $LOG-$i
fi
done
done
