#!/bin/bash

subscription_id="$1"
Setup_Name="$2"
RG_Name="${Setup_Name}rg"
mysql1="$Setup_Name-mysqlha1"
mysql2="$Setup_Name-mysqlha2"
proxy1="$Setup_Name-proxyha1"
proxy2="$Setup_Name-proxyha2"
Storage_Account="$3"
Storage_Account_Key="$4"
mysql1_old_disk="$5"
mysql2_old_disk="$6"
Disk_Name="$7"


>/tmp/$Storage_Account-m1-rstorbkp
>/tmp/$Storage_Account-m2-rstorbkp

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


rm -rf ~/.azure/azureProfile.json

azure login -u abc@example.com -p 123456 <<EOF
y
EOF
azure config mode arm
azure account set $subscription_id


azure vm deallocate -g $RG_Name -n $mysql2
azure vm deallocate -g $RG_Name -n $mysql1

#dt=`date +%d%B%Y-%Hh%Mm%Ss`

for moldvol in $mysql1_old_disk
do
	az vm unmanaged-disk detach --resource-group $RG_Name --vm-name $mysql1 --name $moldvol
	if [ $? -eq 0 ]; then
		echo -e "\n $moldvol Detached Successfully \n"
                echo "$moldvol," >> /tmp/detachvol$Storage_Account
	else
                echo '{"success":"false","code":3001,"message":"Disk Detach Process Failed"}'
                exit 1
        fi
done

for m2oldvol in $mysql2_old_disk
do
        az vm unmanaged-disk detach --resource-group $RG_Name --vm-name $mysql2 --name $m2oldvol
        if [ $? -eq 0 ]; then
                echo -e "\n $m2oldvol Detached Successfully \n"
                echo "$m2oldvol," >> /tmp/detachvol$Storage_Account
        else
                echo '{"success":"false","code":3001,"message":"Disk Detach Process Failed"}'
                exit 1
        fi
done

for mvol in $Disk_Name
do
	
	az storage blob copy start -u https://$Storage_Account.blob.core.windows.net/backup/$mvol.vhd -b $mvol-mysqlha1.vhd -c vhds --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.log

	if [ $? -eq 0 ]; then
		Storage_Size=`az storage blob show --account-name $Storage_Account --account-key $Storage_Account_Key --container-name vhds --name $mvol-mysqlha1.vhd|jq '.metadata.microsoftazurecompute_disksizeingb'|cut -d'"' -f2 2> /tmp/az.log `
		az vm unmanaged-disk attach --resource-group $RG_Name  --vm-name $mysql1 --vhd-uri https://$Storage_Account.blob.core.windows.net/vhds/$mvol-mysqlha1.vhd -n $mvol-mysqlha1 2> /tmp/az.log
		if [ $? -eq 0 ]; then
			echo -e "\n $mvol Attached Successfully \n"
			echo "$mvol-mysqlha1;$storage_type;$Storage_Size" >> /tmp/$Storage_Account-m1-rstorbkp
		else
			echo '{"success":"false","code":3001,"message":"Disk Attach Process Failed"}'
			exit 1
		fi
	else
		for mvol in $Disk_Name
		do
		az storage blob delete -c vhds -n $mvol.vhd --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.lo
		if [ $? -eq 0 ]; then
			echo -e "\n $mvol.vhd Cleaned Successfully \n"
		else
			echo -e "\n $mvol.vhd Cleaned Failed \n"
		fi
		done
		echo '{"success":"false","code":3001,"message":"Backup Disk Clone Failed"}'
        	exit 1
	fi
done

for m2vol in $Disk_Name
do

        az storage blob copy start -u https://$Storage_Account.blob.core.windows.net/backup/$m2vol.vhd -b $m2vol-mysqlha2.vhd -c vhds --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.log

        if [ $? -eq 0 ]; then
		Storage_Size_m2=`az storage blob show --account-name $Storage_Account --account-key $Storage_Account_Key --container-name vhds --name $m2vol-mysqlha2.vhd|jq '.metadata.microsoftazurecompute_disksizeingb'|cut -d'"' -f2 2> /tmp/az.log `
                az vm unmanaged-disk attach --resource-group $RG_Name  --vm-name $mysql2 --vhd-uri https://$Storage_Account.blob.core.windows.net/vhds/$m2vol-mysqlha2.vhd -n $m2vol-mysqlha2 2> /tmp/az.log
                if [ $? -eq 0 ]; then
                        echo -e "\n $m2vol Attached Successfully \n"
                        echo "$m2vol-mysqlha2;$storage_type;$Storage_Size_m2" >> /tmp/$Storage_Account-m2-rstorbkp
                else
                        echo '{"success":"false","code":3001,"message":"Disk Attach Process Failed"}'
                        exit 1
                fi
        else
                for m2voldel in $Disk_Name
                do
                az storage blob delete -c vhds -n $m2voldel.vhd --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.lo
                if [ $? -eq 0 ]; then
                        echo -e "\n $m2voldel.vhd Cleaned Successfully \n"
                else
                        echo -e "\n $m2voldel.vhd Cleaned Failed \n"
                fi
                done
                echo '{"success":"false","code":3001,"message":"Backup Disk Clone Failed"}'
                exit 1
        fi
done


for oldvoldel in $mysql1_old_disk
do
	az storage blob delete -c vhds -n $oldvoldel.vhd --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.lo
	if [ $? -eq 0 ]; then
		echo -e "\n Old Volume $oldvoldel.vhd Cleaned Successfully \n"
	else
		echo -e "\n Old Volume $oldvoldel.vhd Cleaned Failed, Please Delete Manually \n"
	fi
done

for m2oldvoldel in $mysql2_old_disk
do
        az storage blob delete -c vhds -n $m2oldvoldel.vhd --account-key $Storage_Account_Key  --account-name $Storage_Account 2> /tmp/az.lo
        if [ $? -eq 0 ]; then
                echo -e "\n Old Volume $m2oldvoldel.vhd Cleaned Successfully \n"
        else
                echo -e "\n Old Volume $m2oldvoldel.vhd Cleaned Failed, Please Delete Manually \n"
        fi
done

proxy1_pub=`az vm show --resource-group $RG_Name  --name $proxy1 --show-details|grep "publicIps"|cut -d'"' -f4`
proxy2_pub=`az vm show --resource-group $RG_Name  --name $proxy2 --show-details|grep "publicIps"|cut -d'"' -f4`
mysql1_pub=`az vm show --resource-group $RG_Name  --name $mysql1 --show-details|grep "publicIps"|cut -d'"' -f4`
mysql2_pub=`az vm show --resource-group $RG_Name  --name $mysql2 --show-details|grep "publicIps"|cut -d'"' -f4`

proxy1_priv=`az vm show --resource-group $RG_Name  --name $proxy1 --show-details|grep "privateIps"|cut -d'"' -f4`
proxy2_priv=`az vm show --resource-group $RG_Name  --name $proxy2 --show-details|grep "privateIps"|cut -d'"' -f4`
mysql1_priv=`az vm show --resource-group $RG_Name  --name $mysql1 --show-details|grep "privateIps"|cut -d'"' -f4`
mysql2_priv=`az vm show --resource-group $RG_Name  --name $mysql2 --show-details|grep "privateIps"|cut -d'"' -f4`

#/app42RDS/sbin/app42rds_agent_commander $proxy1_pub flush.iptables $proxy1_priv $proxy2_priv
/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$proxy1_pub sudo /app42RDS/sbin/agent flush.iptables $proxy1_priv $proxy2_priv
if [ $? -eq 0 ]; then
	echo "Iptables Flush"
else
#	/app42RDS/sbin/app42rds_agent_commander $proxy2_pub flush.iptables $proxy1_priv $proxy2_priv
	/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$proxy2_pub sudo /app42RDS/sbin/agent flush.iptables $proxy1_priv $proxy2_priv
fi

rm -rf ~/.azure/azureProfile.json

azure login -u abc@example.com -p 123456 <<EOF
y
EOF
azure config mode arm
azure account set $subscription_id

azure vm start -g $RG_Name -n $mysql1
sleep 1m
#/app42RDS/sbin/app42rds_agent_commander $mysql1_pub master.reset
/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$mysql1_pub sudo /app42RDS/sbin/agent master.reset

sleep 30

#/app42RDS/sbin/app42rds_agent_commander $proxy1_pub set.iptables $proxy1_priv $proxy2_priv $mysql1_priv
/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$proxy1_pub sudo /app42RDS/sbin/agent set.iptables $proxy1_priv $proxy2_priv $mysql1_priv
if [ $? -eq 0 ]; then
        echo "Iptables Flush"
else
#        /app42RDS/sbin/app42rds_agent_commander $proxy2_pub set.iptables $proxy1_priv $proxy2_priv $mysql1_priv
	/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$proxy2_pub sudo /app42RDS/sbin/agent set.iptables $proxy1_priv $proxy2_priv $mysql1_priv
fi

azure vm start -g $RG_Name -n $mysql2

rst_pos=`ssh -i /var/keys/app42rds_key -p 22 -tt azureuser@$mysql1_pub cat /tmp/restore_master_position|grep Position|awk '{print $2}'`

#/app42RDS/sbin/app42rds_agent_commander $mysql2_pub restore.change.master 

/usr/bin/ssh -i /var/keys/app42rds_key -tt azureuser@$mysql2_pub sudo /app42RDS/sbin/agent restore.change.master $rst_pos


dsk=`cat /tmp/$Storage_Account-m1-rstorbkp |tr '\n' ' '`
dsk2=`cat /tmp/$Storage_Account-m2-rstorbkp |tr '\n' ' '`
		
#echo '{"code":5000,"success":"true", "message":"Disk Attached", "subscription_id":"'$subscription_id'", "storage_account":"'$Storage_Account'", "VM_Name":"'$vm_name'", "disk_name":"'$dsk'"}'

echo '{"code":5000,"success":"true", "message":"Disk Attached", "subscription_id":"'$subscription_id'", "storage_account":"'$Storage_Account'", "nodes":[{"name":"'$mysql1'", "data_disk":"'$dsk'"}, {"name":"'$mysql2'", "data_disk":"'$dsk2'"}]}'
