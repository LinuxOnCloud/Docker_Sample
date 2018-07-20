#!/bin/bash

subscription_id="$1"
Setup_Name="$2"
RG_Name="${Setup_Name}rg"
postgresql1="$Setup_Name-es3"
postgresql2="$Setup_Name-es4"
proxy1="$Setup_Name-es1"
proxy2="$Setup_Name-es2"


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

echo -e "\nStart VM $postgresql1 \n"
azure vm start -g $RG_Name -n $postgresql1
if [ $? -eq 0 ]; then
	echo -e "\nStart VM $postgresql2 \n"
	azure vm start -g $RG_Name -n $postgresql2
	if [ $? -eq 0 ]; then
		echo -e "\nStart VM $proxy1 \n"
		azure vm start -g $RG_Name -n $proxy1
		if [ $? -eq 0 ]; then
	                echo -e "\nStart VM $proxy2 \n"
			azure vm start -g $RG_Name -n $proxy2
			if [ $? -eq 0 ]; then
				echo '{"code":5000,"success":"true", "message":"App42RDS Setup Has Been Started Successfully", "subscription_id":"'$subscription_id'", "resource_group":"'$RG_Name'", "setup_name":"'$Setup_Name'"}'
			else
				echo '{"success":"false","code":3001,"message":"'$proxy2' VM Could Not Be Started"}'
        			exit 1
			fi
		else
			echo '{"success":"false","code":3001,"message":"'$proxy1' VM Could Not Be Started"}'
                        exit 1
           	fi

	else
		echo '{"success":"false","code":3001,"message":"'$postgresql2' VM Could Not Be Started"}'
		exit 1
	fi
else
	echo '{"success":"false","code":3001,"message":"'$postgresql1' VM Could Not Be Started"}'
        exit 1
fi
