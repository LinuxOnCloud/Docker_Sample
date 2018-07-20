#!/bin/bash

subscription_id="$1"
RG_Name="$2"
vm_name="$3"


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

echo -e "\nStop VM $vm_name \n"
azure vm deallocate -g $RG_Name -n $vm_name
if [ $? -eq 0 ]; then
	echo '{"code":5000,"success":"true", "message":"'$vm_name' VM Stopped Successfully", "subscription_id":"'$subscription_id'", "resource_group":"'$RG_Name'", "vm_name":"'$vm_name'"}'
else
	echo '{"success":"false","code":3001,"message":"'$vm_name' VM Could Not Be Stopped"}'
        exit 1
fi
