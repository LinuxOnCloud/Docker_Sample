#!/bin/bash

subscription_id="$1"
setupName="$2"
resourcegroup="${setupName}rg"
rule_name="$3"

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

for rule in $rule_name
do

	azure network nsg rule delete -g $resourcegroup -a $setupName-proxyhansg -n $rule << EOF
y
EOF
	if [ $? -eq 0 ]; then
		echo -e "\n $rule Deleted Successfully \n"
	else
		echo '{"success":"false","code":3001,"message":"NSG Rule Could Not Be Delete"}'
		exit 1
	fi
done

echo '{"code":5000,"success":"true", "message":"NSG Rule Deleteed Successfully", "subscription_id":"'$subscription_id'", "network_security_group":"'$setupName'-proxyhansg", "rule_name":"'$rule_name'"}'

