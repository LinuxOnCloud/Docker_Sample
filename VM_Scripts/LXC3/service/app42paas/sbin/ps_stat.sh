#!/bin/bash
LOG=/opt/ps_stat/stat/stat

Outfile=/opt/ps_stat/ps_out/cpu

Outfile1=/opt/ps_stat/ps_out/mem

EMAIL="abc@example.com"

if [ ! -d /opt/ps_stat/stat ]; then
        mkdir -p /opt/ps_stat/stat
fi

if [ ! -d /opt/ps_stat/ps_out ]; then
        mkdir -p /opt/ps_stat/ps_out
fi

if [ ! -d /opt/ps_stat/tmp ]; then
        mkdir -p /opt/ps_stat/tmp
fi

for i in $1; do
        echo "$i-PROCESS-UP!" > $LOG-$i

done

while true; do
        for i in $2-$1; do

date >> $Outfile.$i
date >> $Outfile1.$i

#stat=`nmap -p$1 $i |grep tcp|awk '{ print $2 }'`
#servicename=`nmap -p$1 $i |grep tcp|awk '{ print $3 }'`
#dns=`nmap -p$1 $i |grep report|awk '{ print $5 }'`
#process=`ps x |/bin/grep java|/bin/grep maven |/bin/grep $1 |/usr/bin/awk '{print $1}'`
#ip=`ip \r |grep eth0|tail -1|rev|awk '{ print $1}'|rev`
#dns=`dig -x $ip|grep PTR|tail -1|rev|awk '{ print $1 }'|rev`

lxc-ps -n $1 |grep $2|awk '{print $2}'>/opt/ps_stat/tmp/123
tr '\n' ' ' </opt/ps_stat/tmp/123>/opt/ps_stat/tmp/pid
PID=`cat /opt/ps_stat/tmp/pid`

for cpus in $PID
do
cpuadd=`ps -p $cpus -o pcpu |grep -v CPU`
echo "$cpuadd+">>/opt/ps_stat/tmp/cpu

done

for mems in $PID
do
memadd=`ps -o vsz -p $mems|grep -v VSZ`
echo "$memadd+">>/opt/ps_stat/tmp/mem
done

tr '\n' ' ' </opt/ps_stat/tmp/cpu>/opt/ps_stat/tmp/cpudone
tr '\n' ' ' </opt/ps_stat/tmp/mem>/opt/ps_stat/tmp/memdone
rm -rf /opt/ps_stat/tmp/cpu /opt/ps_stat/tmp/mem
cpud=`cat /opt/ps_stat/tmp/cpudone|rev|cut -d '+' -f2-100|rev`
cpuusages=`echo "scale=2; ($cpud)"|bc`

echo "cpuusages=$cpuusages"

memd=`cat /opt/ps_stat/tmp/memdone|rev|cut -d '+' -f2-100|rev`
memus=`echo "scale=2; ($memd)"|bc`
memusages=`echo "scale=2; ($memus/1024/1024)"|bc`
echo "memusages=$memusages"


echo "$cpuusages" >>$Outfile.$i
echo "$memusages">>$Outfile1.$i

if [ -z "$cpuusages" ] || [ -z "$memusages" ]; then
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-PROCESS-DOWN!" ]; then
#                        echo "`date`: Process $1 is Down, Host $dns Service $1 is Down!" | mail -s "Host $dns Service $1 Is DOWN!" $EMAIL
			date

                fi
        echo "$i-PROCESS-DOWN!" > $LOG-$i

else
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-PROCESS-UP!" ]; then
 #                       echo -e "`date`: Process $1 is Up, Host $dns Service $1 is Up!" | mail -s "Host $dns Service $1 is UP!" $EMAIL && mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
			date
                fi
        echo "$i-PROCESS-UP!" > $LOG-$i
fi
done
done

