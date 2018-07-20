#!/bin/bash
system_ip=`ec2metadata --local-ipv4`
system_name=`ec2metadata --security-groups`
instance_id=`ec2metadata --instance-id`
system_pub_ip=`ec2metadata --public-ipv4`
#EMAIL="abc@example.com"
EMAIL="abc@example.com"
THRESHOLD=80
LOG=/opt/disk-data/stat/disk-stat
disk_id=$1


if [ ! -d /opt/disk-data/stat ]; then
        mkdir -p /opt/disk-data/stat
fi

for i in $disk_id; do
        echo "$i-DISK-LOW!" > $LOG-$i
done

while true; do
        for i in $disk_id; do
	dt=`date`
	rm /tmp/disk_h_mail /tmp/disk_n_mail >/dev/null 2>&1
	disk_percent=`df -Th|grep $disk_id|awk '{print $6}'|cut -d'%' -f1`
	total_disk=`df -Th|grep $disk_id|awk '{print $3}'`
	used_disk=`df -Th|grep $disk_id|awk '{print $4}'`

if [ $disk_percent -ge $THRESHOLD ]; then
	echo "$i-DISK-LOW!" > $LOG-$i
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-DISK-HIGH!" ]; then
			echo '<div>
			</div><h1><font size="6" face="Times New Roman" color="red"><div style="font-size:24.0pt">Alert - Disk Usages High</div></font></h1>
			<div style="text-align: justify;">
			<span style="color: red;"><b>Disk Name = '$disk_id'<br />Total Disk = '$total_disk'<br />Used Disk = '$used_disk'<br />Used Disk in Percentage '$disk_percent%'</b></span></div><br />
			<b>Server Name:</b> '$system_name'<br>
			<b>Instance ID:</b> '$instance_id'<br>
			<b>Server Private IP:</b> '$system_ip'<br>
			<b>Server Public IP:</b> '$system_pub_ip'<br>
			<b>Date/Time:</b> '$dt'<br>
			</div>' >/tmp/disk_h_mail
			mail --append="Content-type: text/html" -s "ALARM: '"'Disk-Usages-High'"' Disk Name - $disk_id  $system_name ($instance_id / $system_ip)" $EMAIL </tmp/disk_h_mail
                fi
        echo "$i-DISK-HIGH!" > $LOG-$i
	sleep 12h
else
        STATUS=$(cat $LOG-$i)
                if [ $STATUS != "$i-DISK-LOW!" ]; then
			echo '<h1><font size="6" face="Times New Roman" color="green"><div style="font-size:24.0pt">Alert - Disk Usages Normal</div></font></h1>
                        <div style="text-align: justify;">
			<span style="color: red;"><b>Disk Name = '$disk_id'<br />Total Memory = '$total_disk'<br />Used Memory = '$used_disk'<br />Used Memory in Percentage '$disk_percent%'</b></span></div><br />
                        <b>Server Name:</b> '$system_name'<br>
                        <b>Instance ID:</b> '$instance_id'<br>
                        <b>Server Private IP:</b> '$system_ip'<br>
                        <b>Server Public IP:</b> '$system_pub_ip'<br>
                        <b>Date/Time:</b> '$dt'<br>
                        </div>' >/tmp/disk_n_mail
			mail --append="Content-type: text/html" -s "ALARM: '"'Disk-Usages-Normal'"' Disk Name - $disk_id $system_name ($instance_id / $system_ip)" $EMAIL </tmp/disk_n_mail
                fi
        echo "$i-DISK-LOW!" > $LOG-$i
	sleep 5m
fi
done
done
