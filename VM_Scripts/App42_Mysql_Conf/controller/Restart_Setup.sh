#!/bin/bash

subscription_id="$1"
Setup_Name="$2"
RG_Name="${Setup_Name}rg"
mysql1="$Setup_Name-mysqlha1"
mysql2="$Setup_Name-mysqlha2"
proxy1="$Setup_Name-proxyha1"
proxy2="$Setup_Name-proxyha2"


echo "Setup_Name = $Setup_Name"

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


echo -e "\nStop VM $proxy1 \n"
azure vm deallocate -g $RG_Name -n $proxy1
if [ $? -eq 0 ]; then
	echo -e "\nStop VM $proxy2 \n"
	azure vm deallocate -g $RG_Name -n $proxy2
	if [ $? -eq 0 ]; then
		echo -e "\nStop VM $mysql1 \n"
		azure vm deallocate -g $RG_Name -n $mysql1
		if [ $? -eq 0 ]; then
	                echo -e "\nStop VM $mysql2 \n"
			azure vm deallocate -g $RG_Name -n $mysql2
			if [ $? -eq 0 ]; then
				echo '{"message":"App42RDS Setup Has Been Stopped Successfully"}'
			else
				echo '{"success":"false","code":3001,"message":"'$mysql2' VM Could Not Be Stopped"}'
        			exit 1
			fi
		else
			echo '{"success":"false","code":3001,"message":"'$mysql1' VM Could Not Be Stopped"}'
                        exit 1
           	fi

	else
		echo '{"success":"false","code":3001,"message":"'$proxy2' VM Could Not Be Stopped"}'
		exit 1
	fi
else
	echo '{"success":"false","code":3001,"message":"'$proxy1' VM Could Not Be Stopped"}'
        exit 1
fi

sleep 30

echo -e "\nStart VM $mysql1 \n"
azure vm start -g $RG_Name -n $mysql1
if [ $? -eq 0 ]; then
        echo -e "\nStart VM $mysql2 \n"
        azure vm start -g $RG_Name -n $mysql2
        if [ $? -eq 0 ]; then
                echo -e "\nStart VM $proxy1 \n"
                azure vm start -g $RG_Name -n $proxy1
                if [ $? -eq 0 ]; then
                        echo -e "\nStart VM $proxy2 \n"
                        azure vm start -g $RG_Name -n $proxy2
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true", "message":"App42RDS Setup Has Been Restarted Successfully", "subscription_id":"'$subscription_id'", "resource_group":"'$RG_Name'", "setup_name":"'$Setup_Name'"}'
                        else
                                echo '{"success":"false","code":3001,"message":"'$proxy2' VM Could Not Be Started"}'
                                exit 1
                        fi
                else
                        echo '{"success":"false","code":3001,"message":"'$proxy1' VM Could Not Be Started"}'
                        exit 1
                fi

        else
                echo '{"success":"false","code":3001,"message":"'$mysql2' VM Could Not Be Started"}'
                exit 1
        fi
else
        echo '{"success":"false","code":3001,"message":"'$mysql1' VM Could Not Be Started"}'
        exit 1
fi

