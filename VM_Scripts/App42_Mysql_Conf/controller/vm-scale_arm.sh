#!/bin/bash

subscription_id="$1"
RG_Name="$2"
VM_Name="$3"
VM_Size="$4"
VM_Pub_IP="$5"
No_Of_Conn="$6"
IDB_Pool="$7"


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

/app42RDS/sbin/app42rds_agent_commander $VM_Pub_IP update.my.cnf $No_Of_Conn $IDB_Pool
if [ $? -eq 0 ]; then
        echo -e "\nMySql Configuration Updated Successfully \n"
else
        echo '{"success":"false","code":3001,"message":"MySql Configuration Updation Failed"}'
        exit 1
fi


azure config mode arm
if [ $? -eq 0 ]; then
        echo -e "\nAzure Change Mode ARM Successfully \n"
else
	echo '{"success":"false","code":3001,"message":"Azure Change Mode ARM Failed"}'
        exit 1
fi

azure account set $subscription_id
if [ $? -eq 0 ]; then
        echo -e "\nAzure Set Subscription Successfully \n"
else
	echo '{"success":"false","code":3001,"message":"Azure Set Subscription Failed"}'
        exit 1
fi

azure vm set -g $RG_Name -n $VM_Name -z $VM_Size --disable-boot-diagnostics

if [ $? -eq 0 ]; then
	echo '{"code":5000,"success":"true", "message":"VM Size Update Successfully", "subscription_id":"'$subscription_id'", "resource_group":"'$RG_Name'", "vm_name":"'$VM_Name'", "vm_size":"'$VM_Size'"}'
else
	echo '{"success":"false","code":3001,"message":"VM Size Could Not Be Update"}'
        exit 1
fi

