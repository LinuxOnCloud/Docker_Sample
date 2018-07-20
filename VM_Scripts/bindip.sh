#!/bin/bash
source_ip=$2
service_vm_ip=$3
service_vm_port=$4

# check base vm ip
#vm_ip=`/sbin/ip \r|/bin/grep eth0|/bin/grep src|/usr/bin/awk '{print $9}'`
#echo "vm ip = $vm_ip"

if [ ! -d /var/log/vmpath ]; then
mkdir -p /var/log/vmpath
fi

echo -e "\n`date`" >> /var/log/vmpath/bindip.log

case $1 in

addrule)	
	# set iptable rule
	if [ "$source_ip" = "0.0.0.0" ]; then
		source_ip=0.0.0.0/0
	fi
	echo -e "SRC=$source_ip" |tee -a /var/log/vmpath/bindip.log
	/sbin/iptables -t nat -I PREROUTING -s $source_ip -p tcp -j DNAT --dport $service_vm_port --to-destination $service_vm_ip:$service_vm_port
	if [ $? -eq 0 ]; then
		/bin/echo "/sbin/iptables -t nat -I PREROUTING -s $source_ip -p tcp -j DNAT --dport $service_vm_port --to-destination $service_vm_ip:$service_vm_port" >>/opt/iptab/iptables.sh
		/bin/echo "/sbin/iptables -t nat -I PREROUTING -s $source_ip -p tcp -j DNAT --dport $service_vm_port --to-destination $service_vm_ip:$service_vm_port" >>/var/log/vmpath/bindip.log
		echo "/etc/init.d/iptables save" >> /var/log/vmpath/bindip.log
		/etc/init.d/iptables save |tee -a /var/log/vmpath/bindip.log
		echo '{"code":5000,"success":"true", "message":"Bind IP Rule Added Successfully"}' |tee -a /var/log/vmpath/bindip.log
	else
		echo '{"success":"false","code":8101, "message":"Bind IP Rule Could Not Be Added"}' |tee -a /var/log/vmpath/bindip.log
	fi;;

deleterule)
	# remove iptable rule
	echo "CMD = deleterule">> /var/log/vmpath/bindip.log
	echo "cat -n /opt/iptab/iptables.sh|grep "$source_ip"|grep "$service_vm_ip:$service_vm_port"|awk '{print $1}'" >> /var/log/vmpath/bindip.log
	delete_line=`cat -n /opt/iptab/iptables.sh|grep "$source_ip"|grep "$service_vm_ip:$service_vm_port"|awk '{print $1}'`
	echo "Line No = $delete_line">> /var/log/vmpath/bindip.log
	echo "$delete_line d">/tmp/line
	f_delete_line=`tr -d ' ' </tmp/line`
	/bin/sed -i "$f_delete_line" /opt/iptab/iptables.sh
	echo "/bin/sed -i "$f_delete_line" /opt/iptab/iptables.sh">> /var/log/vmpath/bindip.log
	if [ $? -eq 0 ]; then
		/sbin/iptables -t nat -F 
		/bin/sh /opt/iptab/iptables.sh
		echo "/etc/init.d/iptables save" >> /var/log/vmpath/bindip.log
		/etc/init.d/iptables save |tee -a /var/log/vmpath/bindip.log
		echo '{"code":5000,"success":"true", "message":"Bind IP Rule Removed Successfully"}' |tee -a /var/log/vmpath/bindip.log
        else
                echo '{"success":"false","code":8102, "message":"Bind IP Rule Could Not Be Removed"}' |tee -a /var/log/vmpath/bindip.log
        fi;;

deleteall)
        # remove iptable rule
	echo "CMD = deleteall" >>/var/log/vmpath/bindip.log
        echo "Service VM IP & Port = $service_vm_ip:$service_vm_port" >> /var/log/vmpath/bindip.log
        /bin/sed -i '/'$service_vm_ip:$service_vm_port'/d' /opt/iptab/iptables.sh
        echo "/bin/sed -i '/'$service_vm_ip:$service_vm_port'/d' /opt/iptab/iptables.sh ">> /var/log/vmpath/bindip.log
        if [ $? -eq 0 ]; then
                /sbin/iptables -t nat -F
                /bin/sh /opt/iptab/iptables.sh
                echo "/etc/init.d/iptables save" >> /var/log/vmpath/bindip.log
                /etc/init.d/iptables save |tee -a /var/log/vmpath/bindip.log
                echo '{"code":5000,"success":"true", "message":"Bind IP Rule Removed Successfully"}' |tee -a /var/log/vmpath/bindip.log
        else
                echo '{"success":"false","code":8102, "message":"Bind IP Rule Could Not Be Removed"}' |tee -a /var/log/vmpath/bindip.log
        fi;;


esac

