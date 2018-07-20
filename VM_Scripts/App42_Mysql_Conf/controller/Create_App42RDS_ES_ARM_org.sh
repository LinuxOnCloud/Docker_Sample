#!/bin/bash

date

subscription_id="$1"
setupName="$2"
location="$3"
ES1vm_size="$4"
ES2vm_size="$5"
ES3vm_size="$6"
ES4vm_size="$7"
ES_user_name="$8"
storagetype="$9"
disksize="${10}"
region="$location"
ES_conn="${11}"
allow_ip="${12}"
sub="$subscription_id"
#mysql_version="${14}"


if [ -z $storagetype ] || [ $storagetype == null ]; then
        storagetype="LRS"
fi

if [ -z $disksize ] || [ $disksize == null ]; then
        disksize="100"
fi

if [ -z $ES_conn ] || [ $ES_conn == null ]; then
        ES_conn="150"
fi

if [ -z $allow_ip ] || [ $allow_ip == null ]; then
        allow_ip="0.0.0.0/0"
fi


#if [ -z $mysql_version ] || [ $mysql_version == null ]; then
#        mysql_version="5.6.*"
#fi



echo -e "\nsetupName = $setupName\nlocation = $region\nES1vm_size = $ES1vm_size\nES2vm_size = $ES2vm_size\nES3vm_size = $ES3vm_size\nES4vm_size = $ES4vm_size\nES_user_name = $ES_user_name\nES_databse_name = $ES_databse_name\nstoragetype = $storagetype\ndisksize = $disksize\n"
#mysql_version = $mysql_version\n"

user_password=`openssl rand -base64 10`

#echo "Setup Name = $setupName"
#echo "Region = $region"
#echo "VM Size = $size"
db_url=`date | md5sum|cut -c1-5`

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



#img=`azure vm image list -l $region -p Canonical |grep "14.04.5-LTS"|grep "2016"|sort -r|head -1|awk '{print $8}'`
img=`azure vm image list -l $region -p openlogic|grep "CentOS:6.5"|grep "2016"|awk '{print $8}'`
if [ -z $img ]; then
        echo '{"success":"false","code":3001,"message":"Ubuntu 14.04 LTS 2017 Release Not Found In '$region' Region"}'
        exit 1
fi
echo -e "\n$img\n"

lowercase_setupname=`echo $setupName |tr '[A-Z]' '[a-z]'`
storage_name="$lowercase_setupname$db_url"

resourcegroup="${setupName}rg"

rgremove() {
azure group delete -n $resourcegroup <<EOF
y
EOF
}

echo -e "\nCreating Resource Group\n"

azure group create -n $resourcegroup -l $region
if [ $? -eq 0 ]; then
        echo -e "\nResource Group Created\n"
else
        echo '{"success":"false","code":3001,"message":"Resource Creation Failed"}'
        exit 1
fi

echo -e "\nCreating Storage Account\n"

azure storage account create -g $resourcegroup -l $region --kind Storage --sku-name $storagetype $storage_name
if [ $? -eq 0 ]; then
        storage_key=`azure storage account keys list -g $resourcegroup $storage_name|grep key1|awk '{print $3}'`
        if [ $? -eq 0 ]; then
                                azure storage container create --container vhds -a $storage_name -k $storage_key
                if [ $? -eq 0 ]; then
                                azure storage container create --container backup -a $storage_name -k $storage_key
                        echo -e "\nStorage Account Created\n"
                else
                        echo '{"success":"false","code":3001,"message":"Container Creation Failed"}'
                        rgremove
                        exit 1
                fi
        else
               	echo '{"success":"false","code":3001,"message":"Storage Account Key Cannot Fetch"}'
                rgremove
                exit 1
        fi
else
        echo '{"success":"false","code":3001,"message":"Storage Account Creation Failed"}'
        rgremove
        exit 1
fi

echo -e "\nCreating Virtual Network\n"

azure network vnet create -g $resourcegroup -l $region -n $setupName-vnet -a 10.20.1.0/24
if [ $? -eq 0 ]; then
        azure network vnet subnet create -g $resourcegroup -e $setupName-vnet -n $setupName-subnet -a 10.20.1.0/25
        if [ $? -eq 0 ]; then
                echo -e "\nVirtual Network Created\n"
		else
			echo '{"success":"false","code":3001,"message":"Subnet Creation Failed"}'
			rgremove
			exit 1
		fi
else
	echo '{"success":"false","code":3001,"message":"Virtual Network Creation Failed"}'
    rgremove
    exit 1
fi


echo -e "\nCreating Public IP's\n"

azure network public-ip create -g $resourcegroup -l $region -n ${setupName}es1  -d ${lowercase_setupname}es1 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-es1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-es1 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}es2  -d ${lowercase_setupname}es2 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-es2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-es2 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}es3  -d ${lowercase_setupname}es3 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-es3 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-es3 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}es4 -d ${lowercase_setupname}es4 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-es4 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-es4 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}eslb  -d ${lowercase_setupname}${db_url} -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-eslb Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-eslb Creation Failed"}'
        rgremove
        exit 1
fi


echo -e "\nCreating LoadBalancer\n"

azure network lb create -g $resourcegroup -l $region -n $setupName-lb
if [ $? -eq 0 ]; then
        azure network lb frontend-ip create -g $resourcegroup -l $setupName-lb -i ${setupName}eslb -n $setupName-FrontEndPool
        if [ $? -eq 0 ]; then
                azure network lb address-pool create -g $resourcegroup -l $setupName-lb   -n $setupName-BackEndPool
                if [ $? -eq 0 ]; then
                        azure network lb rule create -g $resourcegroup -l $setupName-lb -n $setupName-LoadBalancerRuleES9200 -p tcp -f 9200 -b 9200   -t $setupName-FrontEndPool -o $setupName-BackEndPool
                        azure network lb rule create -g $resourcegroup -l $setupName-lb -n $setupName-LoadBalancerRuleES9300 -p tcp -f 9300 -b 9300   -t $setupName-FrontEndPool -o $setupName-BackEndPool
                        if [ $? -eq 0 ]; then
                                azure network lb probe create -g $resourcegroup -l $setupName-lb -n $setupName-HealthProbe -p "tcp" -i 15 -c 4
                                if [ $? -eq 0 ]; then
                                        echo -e "\nLoadBalancer Created\n"
                                else
                                        echo '{"success":"false","code":3001,"message":"LoadBalancer HealthProbe Creation Failed"}'
                                        rgremove
                                        exit 1
                                fi
                        else
                                echo '{"success":"false","code":3001,"message":"LoadBalancer LoadBalancerRuleES Creation Failed"}'
								rgremove
                                exit 1
                        fi
                else
                        echo '{"success":"false","code":3001,"message":"LoadBalancer BackEndPool Creation Failed"}'
						rgremove
                        exit 1
                fi
        else
                echo '{"success":"false","code":3001,"message":"LoadBalancer FrontEndPool Creation Failed"}'
		rgremove
                exit 1
        fi
else
        echo '{"success":"false","code":3001,"message":"LoadBalancer Creation Failed"}'
	rgremove
        exit 1
fi

echo -e "\nCreating NIC\n"

azure network nic create -g $resourcegroup -l $region -a 10.20.1.5  --public-ip-name ${setupName}es1 -n $setupName-es1Nic -m $setupName-vnet -k $setupName-subnet -d "/subscriptions/$sub/resourceGroups/$resourcegroup/providers/Microsoft.Network/loadBalancers/$setupName-lb/backendAddressPools/$setupName-BackEndPool"
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-es1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-es1 Creation Failed"}'
		rgremove
        exit 1
fi

azure network nic create -g $resourcegroup -l $region -a 10.20.1.6  --public-ip-name ${setupName}es2 -n $setupName-es2Nic -m $setupName-vnet -k $setupName-subnet -d "/subscriptions/$sub/resourceGroups/$resourcegroup/providers/Microsoft.Network/loadBalancers/$setupName-lb/backendAddressPools/$setupName-BackEndPool"
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-es2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-es2 Creation Failed"}'
	rgremove
        exit 1
fi

azure network nic create -g $resourcegroup -l $region -a 10.20.1.7  --public-ip-name ${setupName}es3 -n $setupName-es3Nic -m $setupName-vnet -k $setupName-subnet  -d "/subscriptions/$sub/resourceGroups/$resourcegroup/providers/Microsoft.Network/loadBalancers/$setupName-lb/backendAddressPools/$setupName-BackEndPool"
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-postgressqlha1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-postgresha1 Creation Failed"}'
		rgremove
        exit 1
fi

azure network nic create -g $resourcegroup -l $region -a 10.20.1.8  --public-ip-name ${setupName}es4 -n $setupName-es4Nic -m $setupName-vnet -k $setupName-subnet  -d "/subscriptions/$sub/resourceGroups/$resourcegroup/providers/Microsoft.Network/loadBalancers/$setupName-lb/backendAddressPools/$setupName-BackEndPool"
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-postgressqlha2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-postgresha2 Creation Failed"}'
		rgremove
        exit 1
fi

echo -e "\nCreating NSG\n"

azure network nsg create -g $resourcegroup -l $region -n $setupName-esnsg
if [ $? -eq 0 ]; then
        azure network nsg rule create -p tcp -r inbound -y 1000 -u 22 -c allow   -g $resourcegroup -a $setupName-esnsg -n $setupName-ESnsgRuleSSH
        if [ $? -eq 0 ]; then
		counter=1010
		rule_no=1
		for ip in $allow_ip
		do
                azure network nsg rule create -p tcp -r inbound -y $counter -u 9200 -c allow   -g $resourcegroup -a $setupName-esnsg -n $setupName-ESnsgRule-$rule_no -f $ip
                azure network nsg rule create -p tcp -r inbound -y 1020 -u 9300 -c allow   -g $resourcegroup -a $setupName-esnsg -n $setupName-ESnsgRule-2 -f $ip
		if [ $? -eq 0 ]; then
			echo "$setupName-ESnsgRule-$rule_no $counter $ip," >> /tmp/$setupName-esnsg
			counter=$((counter+10))
			rule_no=$((rule_no+21))
		else
			echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-ES Rule ES Could Not Be Create"}'
			rgremove
			exit 1
		fi
		done
                if [ $? -eq 0 ]; then
			nsg_rule=`cat /tmp/$setupName-esnsg|tr '\n' ' '`
                        echo -e "\nNSG For $setupName-ES Created\n"
                else
                        echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-ES Rule ES Could Not Be Create"}'
						rgremove
                        exit 1
                fi
        else
                echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-ES Rule SSH Could Not Be Create"}'
				rgremove
                exit 1
        fi
else
        echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-ES Could Not Be Create"}'
		rgremove
        exit 1
fi

echo -e "\nAttaching NSG To NIC\n"

azure network nic set -g $resourcegroup -o $setupName-esnsg -n $setupName-es1Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-es1Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-es1Nic Failed"}'
		rgremove
        exit 1
fi
azure network nic set -g $resourcegroup -o $setupName-esnsg -n $setupName-es2Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-es2Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-es2Nic Failed"}'
	rgremove
        exit 1
fi
azure network nic set -g $resourcegroup -o $setupName-esnsg -n $setupName-es3Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-es3Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-es3Nic Failed"}'
		rgremove
        exit 1
fi
azure network nic set -g $resourcegroup -o $setupName-esnsg -n $setupName-es4Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-es4Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-es4Nic Failed"}'
		rgremove
        exit 1
fi

echo -e "\nCreating AvailabilitySet\n"

azure availset create -g $resourcegroup -l $region -n $setupName-EsAvSet
if [ $? -eq 0 ]; then
        echo -e "\nAvailabilitySet $setupName-ESAvSet Created\n"
else
        echo '{"success":"false","code":3001,"message":"AvailabilitySet '$setupName'-ESAvSet Creation Failed"}'
	rgremove
        exit 1
fi

echo -e "\nCreating Virtual Machine\n"

azure vm create --resource-group $resourcegroup --name $setupName-es1 --location $region --os-type linux --availset-name $setupName-EsAvSet --nic-name $setupName-es1Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $ES1vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-es1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-es1 Creation Failed"}'
		rgremove
        exit 1
fi

azure vm create --resource-group $resourcegroup --name $setupName-es2 --location $region --os-type linux --availset-name $setupName-EsAvSet --nic-name $setupName-es2Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $ES2vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-es2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-es2 Creation Failed"}'
	rgremove
        exit 1
fi

azure vm create --resource-group $resourcegroup --name $setupName-es3 --location $region --os-type linux --availset-name $setupName-EsAvSet --nic-name $setupName-es3Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $ES3vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-es3 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-es3 Creation Failed"}'
	rgremove
        exit 1
fi

azure vm create --resource-group $resourcegroup --name $setupName-es4 --location $region --os-type linux --availset-name $setupName-EsAvSet --nic-name $setupName-es4Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $ES4vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-es4 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-es4 Creation Failed"}'
	rgremove
        exit 1
fi

echo -e "\nAttaching Empty Data Disk For ES DB\n"

azure vm disk attach-new -g $resourcegroup -n $setupName-es1 -z $disksize -d $setupName-es1disk1 -c ReadWrite -o $storage_name -r vhds
if [ $? -eq 0 ]; then
        echo -e "\nData Disk On $setupName-es1 Attached\n"
else
        echo '{"success":"false","code":3001,"message":"Data Disk On '$setupName'-es1 Could Not Be Attach"}'
                rgremove
        exit 1
fi

azure vm disk attach-new -g $resourcegroup -n $setupName-es2 -z $disksize -d $setupName-es2disk1 -c ReadWrite -o $storage_name -r vhds
if [ $? -eq 0 ]; then
        echo -e "\nData Disk On $setupName-es2 Attached\n"
else
        echo '{"success":"false","code":3001,"message":"Data Disk On '$setupName'-es2 Could Not Be Attach"}'
                rgremove
        exit 1
fi

azure vm disk attach-new -g $resourcegroup -n $setupName-es3 -z $disksize -d $setupName-es3disk1 -c ReadWrite -o $storage_name -r vhds
if [ $? -eq 0 ]; then
        echo -e "\nData Disk On $setupName-es3 Attached\n"
else
        echo '{"success":"false","code":3001,"message":"Data Disk On '$setupName'-es3 Could Not Be Attach"}'
		rgremove
        exit 1
fi

echo "azure vm disk attach-new -g $resourcegroup -n $setupName-es4 -z $disksize -d $setupName-es4disk1 -c ReadWrite -o $storage_name -r vhds"
azure vm disk attach-new -g $resourcegroup -n $setupName-es4 -z $disksize -d $setupName-es4disk1 -c ReadWrite -o $storage_name -r vhds
if [ $? -eq 0 ]; then
        echo -e "\nData Disk On $setupName-es4 Attached\n"
else
        echo '{"success":"false","code":3001,"message":"Data Disk On '$setupName'-es4 Could Not Be Attach"}'
		rgremove
        exit 1
fi

es1=`azure network public-ip show -g $resourcegroup -n ${setupName}es1|grep "IP Address"|rev|awk '{print $1}'|rev`
es2=`azure network public-ip show -g $resourcegroup -n ${setupName}es2|grep "IP Address"|rev|awk '{print $1}'|rev`
es3=`azure network public-ip show -g $resourcegroup -n ${setupName}es3|grep "IP Address"|rev|awk '{print $1}'|rev`
es4=`azure network public-ip show -g $resourcegroup -n ${setupName}es4|grep "IP Address"|rev|awk '{print $1}'|rev`
eslb=`azure network public-ip show -g $resourcegroup -n ${setupName}eslb|grep "IP Address"|rev|awk '{print $1}'|rev`

echo "/app42RDS/sbin/Installation_Arm_ES $es1 $es2 $es3 $es4 $ES_conn $setupName"
/app42RDS/sbin/Installation_Arm_ES $es1 $es2 $es3 $es4 $ES_conn $setupName

if [ $? -eq 0 ]; then
        echo -e "\nSetup Installation Completed\n"
else
        echo '{"success":"false","code":3001,"message":"Setup Installation Failed"}'
	rgremove
        exit 1
fi

echo "/app42RDS/sbin/Configuare_Arm_ES $es1 $es2 $es3 $es4 $ES_user_name "$user_password" "$setupName" $ES_conn"
/app42RDS/sbin/Configuare_Arm_ES $es1 $es2 $es3 $es4 $ES_user_name "$user_password" "$setupName" $ES_conn

if [ $? -eq 0 ]; then
        echo -e "\nSetup Configuration Completed\n"
else
        echo '{"success":"false","code":3001,"message":"Setup Configuration Failed"}'
	rgremove
        exit 1
fi

echo -e "\nES1 = $es1\nES2 = $es2\nES3 = $es3\nES4 = $es4\n"

echo -e "\n==============================================================\n"
echo -e "\nDB Url = $eslb \nUser Name = $ES_user_name \nPassword = "$user_password" \n"
echo -e "\nSetup created successefully. Thank You for choosing App42 Elasticsearch Solution\n"
echo -e "\n==============================================================\n"

date


/bin/echo '{"code":5000,"success":"true", "message":"App42RDS Setup Completed Successfully", "subscription_id":"'$subscription_id'", "resource_group":"'$resourcegroup'", "region":"'$region'", "storage_account":"'$storage_name'", "storage_account_key":"'$storage_key'", "setup_ip":"'$eslb'", "network_security_group":"'$setupName'-esnsg", "network_security_group_rule":"'$nsg_rule'",  "nodes":[{"pub_ip":"'$es1'", "private_ip":"10.20.1.5", "type":"Elasticsearch1", "name":"'$setupName'-es1", "data_disk":"'$setupName'-es1disk1;'$storagetype';'$disksize'"}, {"pub_ip":"'$es2'", "private_ip":"10.20.1.6", "type":"Elasticsearch2", "name":"'$setupName'-es2", "data_disk":"'$setupName'-es2disk1;'$storagetype';'$disksize'"}, {"pub_ip":"'$es3'", "private_ip":"10.20.1.7", "type":"Elasticsearch3", "name":"'$setupName'-es3", "data_disk":"'$setupName'-es3disk1;'$storagetype';'$disksize'"}, {"pub_ip":"'$es4'", "private_ip":"10.20.1.8", "type":"Elasticsearch4", "name":"'$setupName'-es4", "data_disk":"'$setupName'-es4disk1;'$storagetype';'$disksize'"}], "setupConfig":{"user_name":"'$ES_user_name'", "password":"'$user_password'"}}'
