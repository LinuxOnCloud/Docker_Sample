#!/bin/bash
system_ip=`ec2metadata --local-ipv4`
system_name=`ec2metadata --security-groups`
instance_id=`ec2metadata --instance-id`
system_pub_ip=`ec2metadata --public-ipv4`
EMAIL="abc@example.com"
THRESHOLD=80
LOG=/opt/mem-data/stat/mem-stat
Outfile=/opt/mem-data/mem_out/mem-log

total_mem=`top -b -n1 | grep "Mem"|awk '{print $2}'|cut -d"k" -f1`

if [ ! -d /opt/mem-data/stat ]; then
        mkdir -p /opt/mem-data/stat
fi

if [ ! -d /opt/mem-data/mem_out ]; then
        mkdir -p /opt/mem-data/mem_out
fi

for i in $instance_id; do
        echo "$i-MEM-LOW!" > $LOG-$i
done

while true; do
        for i in $instance_id; do
	date >> $Outfile.$i
	dt=`date`
	rm /tmp/mem_h_mail /tmp/mem_n_mail >/dev/null 2>&1

	used_mem=`top -b -n1 | grep "Mem"|awk '{print $4}'|cut -d"k" -f1`
	mem_percent=`echo "$used_mem * 100 / $total_mem"|bc`
	echo "Used Memory = $used_mem, Used Memory in Percentage = $mem_percent%" >> $Outfile.$i

if [ $mem_percent -gt $THRESHOLD ]; then
	echo "$i-MEM-LOW!" > $LOG-$i
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-MEM-HIGH!" ]; then
			echo '<div>
			</div><h1><font size="6" face="Times New Roman" color="red"><div style="font-size:24.0pt">Alert - Memory High</div></font></h1>
			<div style="text-align: justify;">
			<span style="color: red;"><b>Total Memory = '$total_mem'<br />Used Memory = '$used_mem'<br />Used Memory in Percentage '$mem_percent%'</b></span></div><br />
			<b>Server Name:</b> '$system_name'<br>
			<b>Instance ID:</b> '$instance_id'<br>
			<b>Server Private IP:</b> '$system_ip'<br>
			<b>Server Public IP:</b> '$system_pub_ip'<br>
			<b>Date/Time:</b> '$dt'<br>
			</div>' >/tmp/mem_h_mail
			mail --append="Content-type: text/html" -s "ALARM: '"'High-Memory'"' $system_name ($instance_id / $system_ip)" $EMAIL </tmp/mem_h_mail
                fi
        echo "$i-MEM-HIGH!" > $LOG-$i
	sleep 2m
else
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-MEM-LOW!" ]; then
			echo '<h1><font size="6" face="Times New Roman" color="green"><div style="font-size:24.0pt">Alert - Memory Normal</div></font></h1>
                        <div style="text-align: justify;">
			<span style="color: red;"><b>Total Memory = '$total_mem'<br />Used Memory = '$used_mem'<br />Used Memory in Percentage '$mem_percent%'</b></span></div><br />
                        <b>Server Name:</b> '$system_name'<br>
                        <b>Instance ID:</b> '$instance_id'<br>
                        <b>Server Private IP:</b> '$system_ip'<br>
                        <b>Server Public IP:</b> '$system_pub_ip'<br>
                        <b>Date/Time:</b> '$dt'<br>
                        </div>' >/tmp/mem_n_mail
			mail --append="Content-type: text/html" -s "ALARM: '"'Memory-Normal'"' $system_name ($instance_id / $system_ip)" $EMAIL </tmp/mem_n_mail
                        mv $Outfile.$i $Outfile.$i-`date +%d-%m-%Y-%H:%M:%S`
                fi
        echo "$i-MEM-LOW!" > $LOG-$i
fi
done
done
