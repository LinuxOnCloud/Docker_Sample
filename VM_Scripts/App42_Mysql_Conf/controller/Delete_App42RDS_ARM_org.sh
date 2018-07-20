#!/bin/bash

subscription_id="$1"
RG_Name="$2"

Storage_Account="$3"
Storage_Account_Key="$4"
Disk_Name="$5"
vm_name1="$6"
vm_name2="$7"

if [ "$true" -eq "true" ]; then

if [ -z $Storage_Account ]; then
	echo '{"success":"false","code":3001,"message":"Storage Account Name Missing"}'
	exit 1
fi

if [ -z $Storage_Account_Key ]; then
	echo '{"success":"false","code":3001,"message":"Storage Account Key Missing"}'
        exit 1
fi

if [ -z $Disk_Name ]; then
	echo '{"success":"false","code":3001,"message":"Data Disk Name Missing"}'
        exit 1
fi

if [ -z $vm_name1 ]; then
	echo '{"success":"false","code":3001,"message":"MySql Master VM Name Missing"}'
        exit 1
fi

if [ -z $vm_name1 ]; then
	echo '{"success":"false","code":3001,"message":"MySql Slave VM Name Missing"}'
        exit 1
fi

rm -rf ~/.azure/azureProfile.json

>/tmp/$Storage_Account-bkp

az login -u abc@example.com -p 123456 2> /tmp/az.log

if [ $? -eq 0 ]; then
        echo -e "\nAzure Login Successfully \n"
else
        echo '{"success":"false","code":3001,"message":"Azure Login Failed"}'
        exit 1
fi

az account set --subscription $subscription_id 2> /tmp/az.log
if [ $? -eq 0 ]; then
        echo -e "\nAzure Set Subscription Successfully \n"
else
        echo '{"success":"false","code":3001,"message":"Azure Set Subscription Failed"}'
        exit 1
fi

dt=`date +%d%B%Y-%Hh%Mm%Ss`

az vm stop  --resource-group $RG_Name --name $vm_name2
if [ $? -eq 0 ]; then
        az vm deallocate --resource-group $RG_Name --name $vm_name2
        echo -e"\n $vm_name2 has been stopped"
else
        az vm start  --resource-group $RG_Name --name $vm_name2
        echo '{"success":"false","code":3001,"message":"Disk Backup Creation Failed, Due To '$vm_name2' Could Not Be Stop"}'
        exit 1
fi

az vm stop  --resource-group $RG_Name --name $vm_name1
if [ $? -eq 0 ]; then
        az vm deallocate --resource-group $RG_Name --name $vm_name1
        echo -e"\n $vm_name1 has been stopped"
else
        az vm start  --resource-group $RG_Name --name $vm_name1
        echo '{"success":"false","code":3001,"message":"Disk Backup Creation Failed, Due To '$vm_name1' Could Not Be Stop"}'
        exit 1
fi

for vol in $Disk_Name
do

        az storage blob copy start --account-name  app42rdsfinalbkp --account-key GUxfTQNfmzKGjMkYKIlVEvu90NKryB7tZmTL1xYJvCSOiYBBay2UuKMt6njZlt8gY6wWp33fIKgpF6vWfFkA== --destination-container vhds --destination-blob $Storage_Account-$vol.vhd --source-account-name $Storage_Account --source-account-key $Storage_Account_Key --source-container vhds --source-blob $vol.vhd 2> /tmp/az.log
        if [ $? -eq 0 ]; then
                echo -e "\n $vol Copy Successfully \n"
        else
				rm -rf ~/.azure/azureProfile.json
				az login -u abc@example.com -p 123456 2> /tmp/az.log
				if [ $? -eq 0 ]; then
					echo -e "\nAzure Login Successfully \n"
				else
					echo '{"success":"false","code":3001,"message":"Azure Login Failed"}'
					fi

				az account set --subscription $subscription_id 2> /tmp/az.log
				if [ $? -eq 0 ]; then
					echo -e "\nAzure Set Subscription Successfully \n"
				else
					echo '{"success":"false","code":3001,"message":"Azure Set Subscription Failed"}'
				fi
				
                az vm start  --resource-group $RG_Name --name $vm_name2
				az vm start  --resource-group $RG_Name --name $vm_name1
                echo '{"success":"false","code":3001,"message":"App42RDS Setup Could Not Be Delete Due to Disk Copy Failed}'
                exit 1
        fi
done

sleep  2m

stat_counter=0
while [ $stat_counter -lt 200 ]; do

copy_status=`az storage blob show --account-name app42rdsfinalbkp --account-key GUxfTQNfmzKGjMkYKIlVEvu90NKryB7tZmTL1xYJvCSOiYBBay2UuKMt6njZlt8gY6wWp33fIKgpF6vWfFkA==  --container-name vhds --name $Storage_Account-$vol.vhd | jq '.properties.copy.status' |cut -d'"' -f2 2> /tmp/az.log `

if [ $copy_status == success ]; then

		echo "RDS Disk Copied"
		stat_counter=11
else
		sleep 10
		stat_counter=$((stat_counter+1))
fi

done

if [ $copy_status == success ]; then

		echo "RDS Disk Copied1"
else
		exit 1
fi

else


echo "######################RDS Setup Deletion Start##########################"

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

azure group delete -n $RG_Name <<EOF
y
EOF

if [ $? -eq 0 ]; then
        echo '{"code":5000,"success":"true", "message":"App42RDS Setup Has Been Deleted", "subscription_id":"'$subscription_id'", "resource_group":"'$RG_Name'"}'
else
        echo '{"success":"false","code":3001,"message":"App42RDS Setup Could Not Be Delete"}'
        exit 1
fi
fi
