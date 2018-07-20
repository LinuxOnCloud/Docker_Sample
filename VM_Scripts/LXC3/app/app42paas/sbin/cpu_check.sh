#!/bin/bash
system_ip=`ec2metadata --local-ipv4`
system_name=`ec2metadata --security-groups`
instance_id=`ec2metadata --instance-id`
system_pub_ip=`ec2metadata --public-ipv4`
EMAIL="abc@example.com"
THRESHOLD=80
LOG=/opt/cpu-data/stat/cpu-stat
Outfile=/opt/cpu-data/cpu_out/cpu-log

if [ ! -d /opt/cpu-data/stat ]; then
        mkdir -p /opt/cpu-data/stat
fi

if [ ! -d /opt/cpu-data/cpu_out ]; then
        mkdir -p /opt/cpu-data/cpu_out
fi

for i in $instance_id; do
        echo "$i-CPU-LOW!" > $LOG-$i
done

while true; do
        for i in $instance_id; do
	date >> $Outfile.$i
	dt=`date`
	rm /tmp/cpu_h_mail /tmp/cpu_n_mail >/dev/null 2>&1

	cpu1=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
	echo "The System CPU  = $cpu1" >>$Outfile.$i
	CPU=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'|cut -d"." -f1`

if [ $CPU -gt $THRESHOLD ]; then
	echo "$i-CPU-LOW!" > $LOG-$i
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-CPU-HIGH!" ]; then
			echo '<div>
			</div><h1><font size="6" face="Times New Roman" color="red"><div style="font-size:24.0pt">Alert - CPU High</div></font></h1>
			<div style="text-align: justify;">
			<span style="color: red;"><b>Current time CPU is = '$cpu1%'</b></span></div><br />
			<b>Server Name:</b> '$system_name'<br>
			<b>Instance ID:</b> '$instance_id'<br>
			<b>Server Private IP:</b> '$system_ip'<br>
			<b>Server Public IP:</b> '$system_pub_ip'<br>
			<b>Date/Time:</b> '$dt'<br>
			</div>' >/tmp/cpu_h_mail
			mail --append="Content-type: text/html" -s "ALARM: '"'High-CPU'"' $system_name ($instance_id / $system_ip)" $EMAIL </tmp/cpu_h_mail
                fi
        echo "$i-CPU-HIGH!" > $LOG-$i
	sleep 2m
else
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-CPU-LOW!" ]; then
			echo '<h1><font size="6" face="Times New Roman" color="green"><div style="font-size:24.0pt">Alert - CPU Normal</div></font></h1>
                        <div style="text-align: justify;">
                        <span style="color: red;"><b>Current time CPU is = '$cpu1%'</b></span></div><br />
                        <b>Server Name:</b> '$system_name'<br>
                        <b>Instance ID:</b> '$instance_id'<br>
                        <b>Server Private IP:</b> '$system_ip'<br>
                        <b>Server Public IP:</b> '$system_pub_ip'<br>
                        <b>Date/Time:</b> '$dt'<br>
                        </div>' >/tmp/cpu_n_mail
			mail --append="Content-type: text/html" -s "ALARM: '"'CPU-Normal'"' $system_name ($instance_id / $system_ip)" $EMAIL </tmp/cpu_n_mail
                        mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
                fi
        echo "$i-CPU-LOW!" > $LOG-$i
fi
done
done
