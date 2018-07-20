#!bin/bash

LOG=/opt/nmap-data/stat/stat-server

Outfile=/opt/nmap-data/nmap_out/log

EMAIL="abc@example.com"

if [ ! -d /opt/nmap-data/stat ]; then
        mkdir -p /opt/nmap-data/stat
fi

if [ ! -d /opt/nmap-data/nmap_out ]; then
        mkdir -p /opt/nmap-data/nmap_out
fi


for i in $2; do
        echo "$i-PORT-UP!" > $LOG.$i

done

while true; do
        for i in $2; do

date >> $Outfile.$i

stat=`nmap -p$1 $i |grep tcp|awk '{ print $2 }'`
servicename=`nmap -p$1 $i |grep tcp|awk '{ print $3 }'`
dns=`nmap -p$1 $i |grep report|awk '{ print $5 }'`

nmap -p$1 $i >> $Outfile.$i

if [ $stat != "open" ]; then
        STATUS=$(cat $LOG.$i)
        	if [ $STATUS != "$i-PORT-DOWN!" ]; then
                        echo "`date`: $servicename Port $1 is Closed on Host $dns, Host $dns Service $servicename is down!" | mail -s "Host $dns Service $servicename port $1 is down!" $EMAIL

                fi
        echo "$i-PORT-DOWN!" > $LOG.$i

else
        STATUS=$(cat $LOG.$i)
                if [ $STATUS != "$i-PORT-UP!" ]; then
                        echo -e "`date`: $servicename Port $1 is Open on Host $dns, Host $dns Service $servicename is up!" | mail -s "Host $dns Service $servicename port $1 is up!" $EMAIL && mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
		fi
        echo "$i-PORT-UP!" > $LOG.$i
fi
done
done
