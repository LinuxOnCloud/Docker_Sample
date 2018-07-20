#!/bin/bash

echo "Enter App42 MySQL HA Setup Name:"
read setupName
echo "Select Region"
echo "1. Central US"
echo "2. South Central US"
echo "3. Singapore"
echo "4. North Europe"
echo "Enter your Option"
read location
case $location in
    1)region="Central US" ;;
    2)region="South Central US" ;;
    3)region="Southeast Asia" ;;
    4)region="North Europe" ;;
esac


echo "Select MySQL VM size"
echo "1. Standrad A1"
echo "2. Standrad A2"
echo "3. Standrad A3"
echo "4. Standrad A4"
echo "Enter your Option"
read vmsize
case $vmsize in
    1)size="Small" ;;
    2)size="Medium" ;;
    3)size="Large" ;;
    4)size="ExtraLarge" ;;
esac

echo "Select MySQL Data Disk size"
echo "1. 100 GB"
echo "2. 200 GB"
echo "3. 300 GB"
echo "4. 400 GB"
echo "Enter your Option"
read datadisksize
case $datadisksize in
    1)disksize="100" ;;
    2)disksize="200" ;;
    3)disksize="300" ;;
    4)disksize="400" ;;
esac


echo "Enter MySQL User Name:"
read user_name

echo "Enter MySQL Database Name:"
read db_name

#date

user_password=`openssl rand -base64 10`

#echo "Setup Name = $setupName"
#echo "Region = $region"
#echo "VM Size = $size"
db_url=`date | md5sum|cut -c1-5`

img=`azure vm image list|grep CentOS-65-2016|awk '{print $2}'`
if [ -z $img ]; then
	echo -e "\nCentos 6.5 2016 Release Not Found In "$region" Region\n"
	exit 1
fi
echo -e "\n$img\n"

echo -e "\nCreating Storage Account\n"

lowercase_setupname=`echo $setupName |tr '[A-Z]' '[a-z]'`
storage_name="$lowercase_setupname$db_url"

azure storage account create --type GRS  --label $storage_name --location "$region" $storage_name
if [ $? -eq 0 ]; then
	storage_key=`azure storage account keys list $storage_name|grep Primary|awk '{print $3}'`
	if [ $? -eq 0 ]; then
		azure storage container create -a $storage_name -k "$storage_key" vhds
		if [ $? -eq 0 ]; then
			echo -e "\nStorage Account Created\n"
		else
			echo -e "\nContainer Creation Failed\n"
#azure storage account delete $storage_name <<EOF
#y
#EOF 
			exit 1
		fi
	else
		echo -e "\nStorage Account Key Cannot Fetch\n"
#azure storage account delete $storage_name <<EOF
#y
#EOF
		exit 1
	fi
else
	echo -e "\nStorage Account Creation Failed\n"
#azure storage account delete $storage_name <<EOF
#y
#EOF
	exit 1
fi


echo -e "\nCreating Virtual Network\n"

azure network vnet create  $setupName-vnet --location "$region" -e 10.20.1.0 -i 24 -p 10.20.1.0 -r 24 -n $setupName-subnet
if [ $? -eq 0 ]; then
	echo -e "\nCreating Virtual Machine $setupName-proxyha1\n"
	azure vm create  $setupName-$db_url.cloudapp.net $img --vm-name $setupName-proxyha1 --vm-size Small --ssh 22  -w $setupName-vnet -S 10.20.1.5  --location "$region" --blob-url https://$storage_name.blob.core.windows.net/vhds/$setupName-proxyha1.vhd --availability-set $setupName-proxyha azureuser --ssh-cert /var/keys/app42rds_key.pub -P
	
	if [ $? -eq 0 ]; then
		echo -e "\nCreating Virtual Machine $setupName-proxyha2\n"
		azure vm create  $setupName-$db_url.cloudapp.net $img --vm-name $setupName-proxyha2 --connect --vm-size Small --ssh 222  -w $setupName-vnet -S 10.20.1.6 --location "$region" --blob-url https://$storage_name.blob.core.windows.net/vhds/$setupName-proxyha2.vhd --availability-set $setupName-proxyha azureuser --ssh-cert /var/keys/app42rds_key.pub -P
	
		if [ $? -eq 0 ]; then
			echo -e "\nCreating Virtual Machine $setupName-mysqlha1\n"
			azure vm create  $setupName-mysqlha.cloudapp.net $img --vm-name $setupName-mysqlha1 --vm-size $size --ssh 22  -w $setupName-vnet -S 10.20.1.7 --location "$region" --blob-url https://$storage_name.blob.core.windows.net/vhds/$setupName-mysqlha1.vhd --availability-set $setupName-mysqlha azureuser --ssh-cert /var/keys/app42rds_key.pub -P
			
			if [ $? -eq 0 ]; then
				echo -e "\nCreating Virtual Machine $setupName-mysqlha2\n"
				azure vm create  $setupName-mysqlha.cloudapp.net $img --vm-name $setupName-mysqlha2 --connect --vm-size $size --ssh 222  -w $setupName-vnet -S 10.20.1.8 --location "$region" --blob-url https://$storage_name.blob.core.windows.net/vhds/$setupName-mysqlha2.vhd --availability-set $setupName-mysqlha azureuser --ssh-cert /var/keys/app42rds_key.pub -P

				if [ $? -eq 0 ]; then
					echo -e "\nCreating Virtual Machine Endpoint (ELB) $setupName-proxyha1\n"
					azure vm endpoint create-multiple  $setupName-proxyha1 --endpoints-config 3306:3306:TCP:30::TCP:3306::15:30:mysqllb::
				
					if [ $? -eq 0 ]; then
						echo -e "\nCreating Virtual Machine Endpoint (ELB) $setupName-proxyha2\n"
						azure vm endpoint create-multiple  $setupName-proxyha2 --endpoints-config 3306:3306:TCP:30::TCP:3306::15:30:mysqllb::
						echo -e "\nAdding Data Disk On $setupName-mysqlha1\n"
						azure vm disk attach-new -c ReadWrite $setupName-mysqlha1 $disksize	
						echo -e "\nAdding Data Disk On $setupName-mysqlha2\n"
						azure vm disk attach-new -c ReadWrite $setupName-mysqlha2 $disksize	
						
						/app42RDS/sbin/Installation $db_name $user_name $setupName "$user_password" "$db_url"
						
						/app42RDS/sbin/Configuare $db_name $user_name $setupName "$user_password" "$db_url"
						if [ $? -eq 0 ]; then
							#date
							echo -e "\n==============================================================\n"
							echo -e "\nDB Url = $setupName-$db_url.cloudapp.net \nDatabase Name = $db_name \nUser Name = $user_name \nPassword = "$user_password" \n"
							echo -e "\nSetup created successefully. Thank You for choosing App42 MySQL HA Solution\n"
							echo -e "\n==============================================================\n"
						else
							echo -e "\nSetup creation failed, Running rollback\n"
							diskproxyha1=`azure vm show "$setupName-proxyha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha1 -b $diskproxyha1 <<EOF
y
EOF
							diskproxyha2=`azure vm show "$setupName-proxyha2" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha2 -b $diskproxyha2 <<EOF
y
EOF
							diskmysqlha1=`azure vm show "$setupName-mysqlha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-mysqlha1 -b $diskmysqlha1 <<EOF
y
EOF
							diskmysqlha2=`azure vm show "$setupName-mysqlha2" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-mysqlha2 -b $diskmysqlha2 <<EOF
y
EOF
azure network vnet delete $setupName-vnet <<EOF
y
EOF
						fi
					else
						echo -e "\nSetup creation failed, Running rollback\n"
						diskproxyha1=`azure vm show "$setupName-proxyha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha1 -b $diskproxyha1 <<EOF
y
EOF
						diskproxyha2=`azure vm show "$setupName-proxyha2" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha2 -b $diskproxyha2 <<EOF
y
EOF
						diskmysqlha1=`azure vm show "$setupName-mysqlha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-mysqlha1 -b $diskmysqlha1 <<EOF
y
EOF
						diskmysqlha2=`azure vm show "$setupName-mysqlha2" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-mysqlha2 -b $diskmysqlha1 <<EOF
y
EOF
azure network vnet delete $setupName-vnet <<EOF
y
EOF
					fi
				else
					echo -e "\n $setupName-mysqlha2 VM creation failed, Running rollback\n"
					diskproxyha1=`azure vm show "$setupName-proxyha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha1 -b $diskproxyha1 <<EOF
y
EOF
					diskproxyha2=`azure vm show "$setupName-proxyha2" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha2 -b $diskproxyha2 <<EOF
y
EOF
					diskmysqlha1=`azure vm show "$setupName-mysqlha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-mysqlha1 -b $diskmysqlha1 <<EOF
y
EOF
azure network vnet delete $setupName-vnet <<EOF
y
EOF
				fi
			else
				echo -e "\n $setupName-mysqlha1 VM creation failed, Running rollback\n"
				diskproxyha1=`azure vm show "$setupName-proxyha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha1 -b $diskproxyha1 <<EOF
y
EOF
				diskproxyha2=`azure vm show "$setupName-proxyha2" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha2 -b $diskproxyha1 <<EOF
y
EOF
azure network vnet delete $setupName-vnet <<EOF
y
EOF
			fi
		else
			echo -e "\n $setupName-proxyha2 VM creation failed, Running rollback\n"
			diskproxyha1=`azure vm show "$setupName-proxyha1" --json|jq '.OSDisk.mediaLink'`
azure vm delete $setupName-proxyha1 -b $diskproxyha1 <<EOF
y
EOF
azure network vnet delete $setupName-vnet <<EOF
y
EOF
		fi
	else
		echo -e "\n $setupName-proxyha1 VM creation failed, Running rollback\n"
azure network vnet delete $setupName-vnet <<EOF
y
EOF
	fi
else
	echo -e "\n $setupName-vnet Virtual Network creation failed\n"
fi	
