#!/bin/bash

subscription_id="$1"
Setup_Name="$2"
RG_Name="${Setup_Name}rg"

Storage_Account="$3"
Storage_Account_Key="$4"
Disk_Name="$5"

>/tmp/$Storage_Account-delbkp

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

counter=0
while [ $counter -lt 1000 ]; do

storage_ac_name=`az storage account list --resource-group $RG_Name|jq '.['$counter'].name'|cut -d'"' -f2 2> /tmp/az.log `

if [ $storage_ac_name == $Storage_Account ]; then
        sku=$counter
        counter=1001
        storage_ty=`az storage account list --resource-group $RG_Name|jq '.['$sku'].sku.name'|cut -d'"' -f2 2> /tmp/az.log `
        if [ $storage_ty == Premium_LRS ]; then
                storage_type=PLRS
        else
                storage_type=LRS
        fi
else
        counter=$((counter+1))
fi
done


for vol in $Disk_Name
do

	Storage_Size=`az storage blob show --account-name $Storage_Account --account-key $Storage_Account_Key --container-name vhds --name $vol.vhd|jq '.metadata.microsoftazurecompute_disksizeingb'|cut -d'"' -f2 2> /tmp/az.log `
	az storage blob delete -c backup -n $vol.vhd --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.lo
	if [ $? -eq 0 ]; then
		echo -e "\n $vol Deleted Successfully \n"
		echo "$vol;$storage_type;$Storage_Size" >> /tmp/$Storage_Account-delbkp
	else
		echo '{"success":"false","code":3001,"message":"Backup Disk Deletion Failed"}'
        	exit 1
	fi
done

dsk=`cat /tmp/$Storage_Account-delbkp |tr '\n' ' '`
		
echo '{"code":5000,"success":"true", "message":"Backup Disk Deleted", "subscription_id":"'$subscription_id'", "storage_account":"'$Storage_Account'", "data_disk":"'$dsk'"}'
