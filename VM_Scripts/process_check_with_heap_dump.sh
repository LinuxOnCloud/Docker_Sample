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
#process=`tail -10 /root/App42_PaaS_Router/App42Router_Console.log |grep "java.lang.OutOfMemoryError"|tail -1|cut -d":" -f1|cut -d"." -f3`
process=`tail -10 /root/App42_PaaS_Router/App42Router-Console.log |grep "java.lang.OutOfMemoryError"|tail -1|cut -d":" -f1|cut -d"." -f3`
#process=`ps x |/bin/grep java|/bin/grep maven |/bin/grep $1 |/usr/bin/awk '{print $1}'`
ip=`ip \r |grep eth0|tail -1|rev|awk '{ print $1}'|rev`
dns=`dig -x $ip|grep PTR|tail -1|rev|awk '{ print $1 }'|rev`

ps aux |/bin/grep java|/bin/grep $1 >> $Outfile.$i
echo -e "\nJava $process \n" >> $Outfile.$i


if [ -n "$process" ]; then
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-PROCESS-DOWN!" ]; then
			pid=`ps x |/bin/grep java|/bin/grep App42Router|awk '{print $1}'`
			echo -e "Full thread dump Java form $1 PID\n">/tmp/dump
			/opt/jdk1.7.0_21/bin/jstack  $pid >> /tmp/App42Router-Thread.dump
			/opt/jdk1.7.0_21/bin/jmap -dump:format=b,file=/tmp/App42Router-Heap.dump $pid
			kill -9 $pid
			gzip /tmp/App42Router-Thread.dump && gzip /tmp/App42Router-Heap.dump
			mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
                        mail -s "Host $dns Service $1 Is DOWN!" $EMAIL < /tmp/dump
			/vmpath/sbin/process App42Router /root/App42_PaaS_Router/ run.sh
			

                fi
        echo "$i-PROCESS-DOWN!" > $LOG-$i

else
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-PROCESS-UP!" ]; then
                        echo -e "`date`: Process $1 is Up, Host $dns Service $1 is Up!" | mail -s "Host $dns Service $1 is UP!" $EMAIL && mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
                fi
        echo "$i-PROCESS-UP!" > $LOG-$i
fi
done
done
