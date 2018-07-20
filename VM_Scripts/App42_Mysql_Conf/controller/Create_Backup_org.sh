#!/bin/bash

subscription_id="$1"
Setup_Name="$2"
RG_Name="${Setup_Name}rg"

Storage_Account="$3"
Storage_Account_Key="$4"
Disk_Name="$5"
vm_name="$6"

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

az vm stop  --resource-group $RG_Name --name $vm_name
if [ $? -eq 0 ]; then
	az vm deallocate --resource-group $RG_Name --name $vm_name
	echo -e"\n $vm_name has been stopped"
else
	az vm start  --resource-group $RG_Name --name $vm_name
	echo '{"success":"false","code":3001,"message":"Disk Backup Creation Failed, Due To '$vm_name' Could Not Be Stop"}'
	exit 1
fi
	


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

	Str_Size=`az storage blob show --account-name $Storage_Account --account-key $Storage_Account_Key --container-name vhds --name $vol.vhd|jq '.properties.contentLength' 2> /tmp/az.log `
	Storage_Size=`echo "$Str_Size/1024/1024/1024"|bc 2> /tmp/az.log `
	az storage blob copy start -u https://$Storage_Account.blob.core.windows.net/vhds/$vol.vhd -b $vol-$dt.vhd -c backup --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.log
	if [ $? -eq 0 ]; then
		echo -e "\n $vol Backuped Successfully \n"
		echo "$vol-$dt;$storage_type;$Storage_Size" >> /tmp/$Storage_Account-bkp
	else
		for vol in $Disk_Name
		do
		az storage blob delete -c backup -n $vol-$dt.vhd --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.lo
		if [ $? -eq 0 ]; then
			echo -e "\n $vol-$dt.vhd Cleaned Successfully \n"
		else
			echo -e "\n $vol-$dt.vhd Cleaned Failed \n"
		fi
		done
		az vm start  --resource-group $RG_Name --name $vm_name
		echo '{"success":"false","code":3001,"message":"Disk Backup Creation Failed"}'
        	exit 1
	fi
done

az vm start  --resource-group $RG_Name --name $vm_name
if [ $? -eq 0 ]; then
        echo -e"\n $vm_name has been start"
else
        echo -e"\n $vm_name Start Command Failed Please Start VM Manually"
fi


dsk=`cat /tmp/$Storage_Account-bkp |tr '\n' ' '`
		
echo '{"code":5000,"success":"true", "message":"Disk Backup Has Been Completed", "subscription_id":"'$subscription_id'", "storage_account":"'$Storage_Account'", "data_disk":"'$dsk'"}'
