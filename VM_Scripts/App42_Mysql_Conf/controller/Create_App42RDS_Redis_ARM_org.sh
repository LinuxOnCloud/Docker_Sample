#!/bin/bash

date

subscription_id="$1"
setupName="$2"
location="$3"
proxy1vm_size="$4"
proxy2vm_size="$5"
redis_master_vm_size="$6"
redis_slave_vm_size="$7"
redis_mem="$8"
redis_conn="$9"
storagetype="${10}"
disksize="${11}"
region="$location"
allow_ip="${12}"
sub="$subscription_id"


if [ -z $storagetype ] || [ $storagetype == null ]; then
        storagetype="LRS"
fi

if [ -z $disksize ] || [ $disksize == null ]; then
        disksize="100"
fi

if [ -z $redis_conn ] || [ $redis_conn == null ]; then
        redis_conn="150"
fi

if [ -z $allow_ip ] || [ $allow_ip == null ]; then
        allow_ip="0.0.0.0/0"
fi


#if [ -z $mysql_version ] || [ $mysql_version == null ]; then
#        mysql_version="5.6.*"
#fi



echo -e "\nsetupName = $setupName\nlocation = $region\nproxy1vm_size = $proxy1vm_size\nproxy2vm_size = proxy2vm_size\nredis_master_vm_size = $redis_master_vm_size\nredis_slave_vm_size = $redis_slave_vm_size\nredis_memory = $redis_mem\nredis_max_connection = $redis_conn\nstoragetype = $storagetype\ndisksize = $disksize\n"
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



#img=`azure vm image list -l southindia -p Canonical |grep "14.04.5-LTS"|sort -r|head -1|awk '{print $8}'`
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

azure network public-ip create -g $resourcegroup -l $region -n ${setupName}p1  -d ${lowercase_setupname}p1 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-proxyha1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-proxyha1 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}p2  -d ${lowercase_setupname}p2 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-proxyha2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-proxyha2 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}redis1  -d ${lowercase_setupname}redis1 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-redisha1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-redisha1 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}redis2 -d ${lowercase_setupname}redis2 -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-redisha2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-redisha2 Creation Failed"}'
        rgremove
        exit 1
fi
azure network public-ip create -g $resourcegroup -l $region -n ${setupName}proxylb  -d ${lowercase_setupname}${db_url} -a static -i 4
if [ $? -eq 0 ]; then
        echo -e "\nPublic IP For $setupName-proxylb Created\n"
else
        echo '{"success":"false","code":3001,"message":"Public IP For '$setupName'-proxylb Creation Failed"}'
        rgremove
        exit 1
fi


echo -e "\nCreating LoadBalancer\n"

azure network lb create -g $resourcegroup -l $region -n $setupName-lb
if [ $? -eq 0 ]; then
        azure network lb frontend-ip create -g $resourcegroup -l $setupName-lb -i ${setupName}proxylb -n $setupName-FrontEndPool
        if [ $? -eq 0 ]; then
                azure network lb address-pool create -g $resourcegroup -l $setupName-lb   -n $setupName-BackEndPool
                if [ $? -eq 0 ]; then
                        azure network lb rule create -g $resourcegroup -l $setupName-lb -n $setupName-LoadBalancerRuleRedis -p tcp -f 6379 -b 6379   -t $setupName-FrontEndPool -o $setupName-BackEndPool
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
                                echo '{"success":"false","code":3001,"message":"LoadBalancer LoadBalancerRuleRedis Creation Failed"}'
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

azure network nic create -g $resourcegroup -l $region -a 10.20.1.5  --public-ip-name ${setupName}p1 -n $setupName-proxyha1Nic -m $setupName-vnet -k $setupName-subnet -d "/subscriptions/$sub/resourceGroups/$resourcegroup/providers/Microsoft.Network/loadBalancers/$setupName-lb/backendAddressPools/$setupName-BackEndPool"
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-proxyha1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-proxyha1 Creation Failed"}'
		rgremove
        exit 1
fi

azure network nic create -g $resourcegroup -l $region -a 10.20.1.6  --public-ip-name ${setupName}p2 -n $setupName-proxyha2Nic -m $setupName-vnet -k $setupName-subnet -d "/subscriptions/$sub/resourceGroups/$resourcegroup/providers/Microsoft.Network/loadBalancers/$setupName-lb/backendAddressPools/$setupName-BackEndPool"
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-proxyha2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-proxyha2 Creation Failed"}'
	rgremove
        exit 1
fi

azure network nic create -g $resourcegroup -l $region -a 10.20.1.7  --public-ip-name ${setupName}redis1 -n $setupName-redisha1Nic -m $setupName-vnet -k $setupName-subnet
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-redisha1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-redisha1 Creation Failed"}'
		rgremove
        exit 1
fi

azure network nic create -g $resourcegroup -l $region -a 10.20.1.8  --public-ip-name ${setupName}redis2 -n $setupName-redisha2Nic -m $setupName-vnet -k $setupName-subnet
if [ $? -eq 0 ]; then
        echo -e "\nNIC For $setupName-redisha2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"NIC For '$setupName'-redisha2 Creation Failed"}'
		rgremove
        exit 1
fi

echo -e "\nCreating NSG\n"

azure network nsg create -g $resourcegroup -l $region -n $setupName-proxyhansg
if [ $? -eq 0 ]; then
        azure network nsg rule create -p tcp -r inbound -y 1000 -u 22 -c allow   -g $resourcegroup -a $setupName-proxyhansg -n $setupName-ProxynsgRuleSSH
        if [ $? -eq 0 ]; then
		counter=1010
		rule_no=1
		for ip in $allow_ip
		do
                azure network nsg rule create -p tcp -r inbound -y $counter -u 6379 -c allow   -g $resourcegroup -a $setupName-proxyhansg -n $setupName-ProxynsgRuleRedis-$rule_no -f $ip
		if [ $? -eq 0 ]; then
			echo "$setupName-ProxynsgRuleRedis-$rule_no $counter $ip," >> /tmp/$setupName-proxyhansg
			counter=$((counter+10))
			rule_no=$((rule_no+1))
		else
			echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-proxyha Rule Redis Could Not Be Create"}'
			rgremove
			exit 1
		fi
		done
                if [ $? -eq 0 ]; then
			nsg_rule=`cat /tmp/$setupName-proxyhansg|tr '\n' ' '`
                        echo -e "\nNSG For $setupName-proxyha Created\n"
                else
                        echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-proxyha Rule Redis Could Not Be Create"}'
						rgremove
                        exit 1
                fi
        else
                echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-proxyha Rule SSH Could Not Be Create"}'
				rgremove
                exit 1
        fi
else
        echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-proxyha Could Not Be Create"}'
		rgremove
        exit 1
fi

azure network nsg create -g $resourcegroup -l $region -n $setupName-redishansg
if [ $? -eq 0 ]; then
        azure network nsg rule create -p tcp -r inbound -y 1000 -u 22 -c allow   -g $resourcegroup -a $setupName-redishansg -n $setupName-RedisnsgRuleSSH
        if [ $? -eq 0 ]; then
                echo -e "\nNSG For $setupName-redisha Created\n"
        else
                echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-redisha Rule SSH Could Not Be Create"}'
				rgremove
                exit 1
        fi
else
        echo '{"success":"false","code":3001,"message":"NSG For '$setupName'-redisha Could Not Be Create"}'
		rgremove
        exit 1
fi

echo -e "\nAttaching NSG To NIC\n"

azure network nic set -g $resourcegroup -o $setupName-proxyhansg -n $setupName-proxyha1Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-proxyha1Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-proxyha1Nic Failed"}'
		rgremove
        exit 1
fi
azure network nic set -g $resourcegroup -o $setupName-proxyhansg -n $setupName-proxyha2Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-proxyha2Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-proxyha2Nic Failed"}'
	rgremove
        exit 1
fi
azure network nic set -g $resourcegroup -o $setupName-redishansg -n $setupName-redisha1Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-redisha1Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-redisha1Nic Failed"}'
		rgremove
        exit 1
fi
azure network nic set -g $resourcegroup -o $setupName-redishansg -n $setupName-redisha2Nic
if [ $? -eq 0 ]; then
        echo -e "\nNSG Attached to NIC $setupName-redisha2Nic Created\n"
else
        echo '{"success":"false","code":3001,"message":"NSG Attached to NIC '$setupName'-redisha2Nic Failed"}'
		rgremove
        exit 1
fi

echo -e "\nCreating AvailabilitySet\n"

azure availset create -g $resourcegroup -l $region -n $setupName-pAvSet
if [ $? -eq 0 ]; then
        echo -e "\nAvailabilitySet $setupName-proxyhaAvSet Created\n"
else
        echo '{"success":"false","code":3001,"message":"AvailabilitySet '$setupName'-proxyhaAvSet Creation Failed"}'
	rgremove
        exit 1
fi
azure availset create -g $resourcegroup -l $region -n $setupName-redisAvSet
if [ $? -eq 0 ]; then
        echo -e "\nAvailabilitySet $setupName-redishaAvSet Created\n"
else
        echo '{"success":"false","code":3001,"message":"AvailabilitySet '$setupName'-redishaAvSet Creation Failed"}'
		rgremove
        exit 1
fi

echo -e "\nCreating Virtual Machine\n"

azure vm create --resource-group $resourcegroup --name $setupName-proxyha1 --location $region --os-type linux --availset-name $setupName-pAvSet --nic-name $setupName-proxyha1Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $proxy1vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-proxyha1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-proxyha1 Creation Failed"}'
		rgremove
        exit 1
fi

azure vm create --resource-group $resourcegroup --name $setupName-proxyha2 --location $region --os-type linux --availset-name $setupName-pAvSet --nic-name $setupName-proxyha2Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $proxy2vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-proxyha2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-proxyha2 Creation Failed"}'
	rgremove
        exit 1
fi

azure vm create --resource-group $resourcegroup --name $setupName-redisha1 --location $region --os-type linux --availset-name $setupName-redisAvSet --nic-name $setupName-redisha1Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $redis_master_vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-redisha1 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-redisha1 Creation Failed"}'
	rgremove
        exit 1
fi

azure vm create --resource-group $resourcegroup --name $setupName-redisha2 --location $region --os-type linux --availset-name $setupName-redisAvSet --nic-name $setupName-redisha2Nic --vnet-name $setupName-vnet --vnet-subnet-name $setupName-subnet --storage-account-name $storage_name --image-urn $img --ssh-publickey-file /var/keys/app42rds_key.pub --admin-username azureuser  --vm-size $redis_slave_vm_size --disable-boot-diagnostics
if [ $? -eq 0 ]; then
        echo -e "\nVirtual Machine $setupName-redisha2 Created\n"
else
        echo '{"success":"false","code":3001,"message":"Virtual Machine '$setupName'-redisha2 Creation Failed"}'
	rgremove
        exit 1
fi

echo -e "\nAttaching Empty Data Disk For Redis\n"

#echo "azure vm disk attach-new -g $resourcegroup -n $setupName-redisha1 -z $disksize -d $setupName-redisha1disk1 -c ReadWrite -o $storage_name -r vhds"

azure vm disk attach-new -g $resourcegroup -n $setupName-redisha1 -z $disksize -d $setupName-redisha1disk1 -c ReadWrite -o $storage_name -r vhds
if [ $? -eq 0 ]; then
        echo -e "\nData Disk On $setupName-redisha1 Attached\n"
else
        echo '{"success":"false","code":3001,"message":"Data Disk On '$setupName'-redisha1 Could Not Be Attach"}'
		rgremove
        exit 1
fi

echo "azure vm disk attach-new -g $resourcegroup -n $setupName-redisha2 -z $disksize -d $setupName-redisha2disk1 -c ReadWrite -o $storage_name -r vhds"
azure vm disk attach-new -g $resourcegroup -n $setupName-redisha2 -z $disksize -d $setupName-redisha2disk1 -c ReadWrite -o $storage_name -r vhds
if [ $? -eq 0 ]; then
        echo -e "\nData Disk On $setupName-redisha2 Attached\n"
else
        echo '{"success":"false","code":3001,"message":"Data Disk On '$setupName'-redisha2 Could Not Be Attach"}'
		rgremove
        exit 1
fi

proxyha1=`azure network public-ip show -g $resourcegroup -n ${setupName}p1|grep "IP Address"|rev|awk '{print $1}'|rev`
proxyha2=`azure network public-ip show -g $resourcegroup -n ${setupName}p2|grep "IP Address"|rev|awk '{print $1}'|rev`
redisha1=`azure network public-ip show -g $resourcegroup -n ${setupName}redis1|grep "IP Address"|rev|awk '{print $1}'|rev`
redisha2=`azure network public-ip show -g $resourcegroup -n ${setupName}redis2|grep "IP Address"|rev|awk '{print $1}'|rev`
proxylb=`azure network public-ip show -g $resourcegroup -n ${setupName}proxylb|grep "IP Address"|rev|awk '{print $1}'|rev`

echo "/app42RDS/sbin/Installation_Arm_Redis $proxyha1 $proxyha2 $redisha1 $redisha2 $redis_conn $setupName"
/app42RDS/sbin/Installation_Arm_Redis $proxyha1 $proxyha2 $redisha1 $redisha2 $redis_conn $setupName

if [ $? -eq 0 ]; then
        echo -e "\nSetup Installation Completed\n"
else
        echo '{"success":"false","code":3001,"message":"Setup Installation Failed"}'
	rgremove
        exit 1
fi

echo "/app42RDS/sbin/Configuare_Arm_Redis $proxyha1 $proxyha2 $redisha1 $redisha2  $redis_mem $redis_conn "$user_password" $setupName"
/app42RDS/sbin/Configuare_Arm_Redis $proxyha1 $proxyha2 $redisha1 $redisha2  $redis_mem $redis_conn "$user_password" $setupName
if [ $? -eq 0 ]; then
        echo -e "\nSetup Configuration Completed\n"
else
        echo '{"success":"false","code":3001,"message":"Setup Configuration Failed"}'
	rgremove
        exit 1
fi

echo -e "\nProxyHA1 = $proxyha1\nProxyHA2 = $proxyha2\nRedisHA1 = $redisha1\nRedisHA2 = $redisha2\n"

echo -e "\n==============================================================\n"
echo -e "\nDB Url = $proxylb \nDB Memory = $redis_mem \nPassword = "$user_password" \n"
echo -e "\nSetup created successefully. Thank You for choosing App42 Redis HA Solution\n"
echo -e "\n==============================================================\n"

date



/bin/echo '{"code":5000,"success":"true", "message":"App42RDS Setup Completed Successfully", "subscription_id":"'$subscription_id'", "resource_group":"'$resourcegroup'", "region":"'$region'", "storage_account":"'$storage_name'", "storage_account_key":"'$storage_key'", "setup_ip":"'$proxylb'", "network_security_group":"'$setupName'-proxyhansg", "network_security_group_rule":"'$nsg_rule'",  "nodes":[{"pub_ip":"'$proxyha1'", "private_ip":"10.20.1.5", "type":"proxy1", "name":"'$setupName'-proxyha1"}, {"pub_ip":"'$proxyha2'", "private_ip":"10.20.1.6", "type":"proxy2", "name":"'$setupName'-proxyha2"}, {"pub_ip":"'$redisha1'", "private_ip":"10.20.1.7", "type":"master", "name":"'$setupName'-redisha1", "data_disk":"'$setupName'-redisha1disk1;'$storagetype';'$disksize'"}, {"pub_ip":"'$redisha2'", "private_ip":"10.20.1.8", "type":"slave", "name":"'$setupName'-redisha2", "data_disk":"'$setupName'-redisha2disk1;'$storagetype';'$disksize'"}], "setupConfig":{"redis_memory":"'$redis_mem'", "password":"'$user_password'", "redis_max_connection":"'$redis_conn'"}}'
