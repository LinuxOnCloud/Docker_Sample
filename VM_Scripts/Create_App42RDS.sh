echo "Please Enter App42RDS Setup Name:"
read setupName
echo "Please Select Region"
echo "1. Central US"
echo "2. West US"
echo "3. Singapore"
echo "4. India"
echo "Enter your Option"
read location
case $location in
    1)region="Central US" ;;
    2)region="West US" ;;
    3)region="Singapore" ;;
    4)region="India" ;;
esac


echo "Please select MySQL VM size"
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

echo "Please select MySQL Data Disk size"
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


echo "Please Enter MySQL User Name:"
read user_name

echo "Please Enter MySQL Database Name:"
read db_name

user_password=`openssl rand -base64 10`

#echo "Setup Name = $setupName"
#echo "Region = $region"
#echo "VM Size = $size"


echo -e "\nCreating Virtual Network\n"

azure network vnet create  $setupName-vnet --location "$region" -e 10.20.1.0 -i 24 -p 10.20.1.0 -r 24 -n $setupName-subnet
if [ $? -eq 0 ]; then
	echo -e "\nCreating Virtual Machine $setupName-proxyha1\n"
	azure vm create  $setupName-proxyha.cloudapp.net MysqlProxyHA1 --vm-name $setupName-proxyha1 --vm-size Small --ssh 22  -w $setupName-vnet -S 10.20.1.5 --location "$region" --availability-set $setupName-proxyha azureuser --ssh-cert /app42RDS/sbin/app42rds_key.pub -P
	
	if [ $? -eq 0 ]; then
		echo -e "\nCreating Virtual Machine $setupName-proxyha2\n"
		azure vm create  $setupName-proxyha.cloudapp.net MysqlProxyHA2 --vm-name $setupName-proxyha2 --connect --vm-size Small --ssh 222  -w $setupName-vnet -S 10.20.1.6 --location "$region" --availability-set $setupName-proxyha azureuser --ssh-cert /app42RDS/sbin/app42rds_key.pub -P
	
		if [ $? -eq 0 ]; then
			echo -e "\nCreating Virtual Machine $setupName-mysqlha1\n"
			azure vm create  $setupName-mysqlha.cloudapp.net MysqlMaster --vm-name $setupName-mysqlha1 --vm-size $size --ssh 22  -w $setupName-vnet -S 10.20.1.7 --location "$region" --availability-set $setupName-mysqlha azureuser --ssh-cert /app42RDS/sbin/app42rds_key.pub -P
			
			if [ $? -eq 0 ]; then
				echo -e "\nCreating Virtual Machine $setupName-mysqlha2\n"
				azure vm create  $setupName-mysqlha.cloudapp.net MysqlSlave --vm-name $setupName-mysqlha2 --connect --vm-size $size --ssh 222  -w $setupName-vnet -S 10.20.1.8 --location "$region" --availability-set $setupName-mysqlha azureuser --ssh-cert /app42RDS/sbin/app42rds_key.pub -P

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
						
						/app42RDS/sbin/Configuare_App42RDS.sh $db_name $user_name $setupName "$user_password"
						if [ $? -eq 0 ]; then
							echo -e "\n==============================================================\n"
							echo -e "\nDB Url = $setupName-proxyha.cloudapp.net \nDatabase Name = $db_name \nUser Name = $user_name \nPassword = "$user_password" \n"
							echo -e "\nSetup created successefully. Thank You for choosing App42RDS\n"
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
