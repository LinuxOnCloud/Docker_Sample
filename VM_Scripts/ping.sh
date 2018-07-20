#!bin/bash

LOG=/tmp/ping/log

Outfile=/tmp/ping_out/ping-out

EMAIL="abc@example.com"

if [ ! -d /tmp/ping ]; then
	mkdir -p /tmp/ping
fi

if [ ! -d /tmp/ping_out ]; then
        mkdir -p /tmp/ping_out
fi

if [ ! -d /tmp/trace_out ]; then
        mkdir -p /tmp/trace_out
fi

for i in $@; do
        echo "$i-UP!" > $LOG.$i

done

while true; do
        for i in $@; do

date >> $Outfile.$i

ping -i 2 -c 10 $i >> $Outfile.$i

if [ $? -ne 0 ]; then
        STATUS=$(cat $LOG.$i)
                if [ $STATUS != "$i-DOWN!" ]; then
                        echo "`date`: ping failed, Server $i host is down!" | mail -s "Server $i host is down!" $EMAIL && traceroute $i > /tmp/trace_out/tracert-$i-`date +%d-%m-%Y-%H:%M:%S`

                fi
        echo "$i-DOWN!" > $LOG.$i

else
        STATUS=$(cat $LOG.$i)
                if [ $STATUS != "$i-UP!" ]; then
                        echo -e "`date`: ping OK, Server $i host is up!" | mail -s " Server $i host is up!" $EMAIL && mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
                fi
        echo "$i-UP!" > $LOG.$i
fi
done
done
