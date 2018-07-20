#!/bin/bash

subscription_id="$1"
setupName="$2"
resourcegroup="${setupName}rg"
allow_ip="$3"
rule_name="$4"
delete_rule_name="$4"
priority="$5"


rm -rf ~/.azure/azureProfile.json

azure login -u abc@example.com -p 123456 <<EOF
y
EOF

if [ $? -eq 0 ]; then
        echo -e "\nAzure Login Successfully \n"
else
	echo '{"success":"false","code":3001,"message":"Azure Login Failed"}'
        exit 1
fi

azure config mode arm
if [ $? -eq 0 ]; then
        echo -e "\nAzure Change Mode ARM Successfully \n"
else
        echo '{"success":"false","code":3001,"message":"Azure Change Mode ARM Failed Failed"}'
        exit 1
fi


azure account set $subscription_id
if [ $? -eq 0 ]; then
        echo -e "\nAzure Set Subscription Successfully \n"
else
	echo '{"success":"false","code":3001,"message":"Azure Set Subscription Failed"}'
        exit 1
fi

>/tmp/$setupName-proxyhansg

for ip in $allow_ip
do

	azure network nsg rule create -p tcp -r inbound -y $priority -u 3306 -c allow   -g $resourcegroup -a $setupName-proxyhansg -n $setupName-ProxynsgRuleMySql-$rule_name -f $ip
	if [ $? -eq 0 ]; then
		echo -e "\n $ip Allowed Successfully \n"
		echo "$setupName-ProxynsgRuleMySql-$rule_name $priority $ip," >> /tmp/$setupName-proxyhansg
		priority=$((priority+10))
		rule_name=$((rule_name+1))
	else
		for ip in $allow_ip
		do
		azure network nsg rule delete -g $resourcegroup -a $setupName-proxyhansg -n $setupName-ProxynsgRuleMySql-$delete_rule_name << EOF
y
EOF
		if [ $? -eq 0 ]; then
			delete_rule_name=$((delete_rule_name+1))
			echo -e "\n $setupName-ProxynsgRuleMySql-$delete_rule_name Deleted Successfully \n"
		else
			echo -e "\n $setupName-ProxynsgRuleMySql-$delete_rule_name Could Not Be Delete \n"
		fi
		done
		echo '{"success":"false","code":3001,"message":"NSG Rule Creation Failed"}'
        	exit 1
	fi
done

nsg_rule=`cat /tmp/$setupName-proxyhansg |tr '\n' ' '`
		
echo '{"code":5000,"success":"true", "message":"NSG Rule Added Successfully", "subscription_id":"'$subscription_id'", "network_security_group":"'$setupName'-proxyhansg", "network_security_group_rule":"'$nsg_rule'"}'
