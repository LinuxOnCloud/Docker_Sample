#!/bin/bash

#EMAIL="abc@example.com"
EMAIL="abc@example.com"
ip=`/usr/bin/ec2metadata --local-ipv4`
region=`/usr/bin/ec2metadata --availability-zone|rev|cut -c 2-20|rev`
ins_id=`/usr/bin/ec2metadata --instance-id`


if [ -d "/opt/ec2-api-tools-1.6.8.0" ]; then
	export EC2_HOME="/opt/ec2-api-tools-1.6.8.0"
	export AWS_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxx"
	export AWS_SECRET_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	PATH=$PATH:$EC2_HOME/bin
else
	echo "EC2 API TOOLS Dose Not Exist" >/tmp/SnapShot_detail
	mail -s "InstanceID - $ins_id IP - $ip SnapShot Creation Failed" $Email </tmp/SnapShot_detail
	exit 1
fi

if [ -d "/opt/jdk1.7.0_21" ]; then

	if [ -z $JAVA_HOME ]; then
		export JAVA_HOME="/opt/jdk1.7.0_21"
		PATH=$PATH:$EC2_HOME/bin:$JAVA_HOME/bin
	fi
else
	echo "Java Dir Dose Not Exist" >/tmp/SnapShot_detail
        mail -s "InstanceID - $ins_id IP - $ip SnapShot Creation Failed" $Email </tmp/SnapShot_detail
        exit 1
fi

vm_id=`/opt/ec2-api-tools-1.6.8.0/bin/ec2-describe-instances --region $region $ins_id|grep Name|awk '{print $5}'`
vol_id=`/opt/ec2-api-tools-1.6.8.0/bin/ec2-describe-volumes --region $region|grep $ins_id|grep false|awk '{print $2}'`

if [ -z $vol_id ]; then
	echo "LVM Volume Dose Not Exist" >/tmp/SnapShot_detail
        mail -s "InstanceID - $ins_id IP - $ip SnapShot Creation Failed" $Email </tmp/SnapShot_detail
        exit 1
fi


echo -e "\n/opt/ec2-api-tools-1.6.8.0/bin/ec2-create-snapshot --region $region -d "$vm_id InstanceID - $ins_id EBS LVM From $vol_id - `date +%d%b%Ytime%H:%M`" $vol_id \n" >/tmp/SnapShot_detail
/opt/ec2-api-tools-1.6.8.0/bin/ec2-create-snapshot --region $region -d "$vm_id InstanceID - $ins_id EBS LVM From $vol_id - `date +%d%b%Ytime%H:%M`" $vol_id >>/tmp/SnapShot_detail
snap_id=`cat /tmp/SnapShot_detail|grep SNAPSHOT|awk '{print $2}'`
sleep 20m
echo -e "\n" >>/tmp/SnapShot_detail
/opt/ec2-api-tools-1.6.8.0/bin/ec2-describe-snapshots --region $region $snap_id >> /tmp/SnapShot_detail

echo -e "\n/opt/ec2-api-tools-1.6.8.0/bin/ec2-describe-snapshots --region $region |grep $vol_id|sort -k 5|grep -v `date +%Y-%m-%d`|grep -v `date +%Y-%m-%d -d '1 day ago'`|grep -v `date +%Y-%m-%d -d '2 day ago'`|grep -v `date +%Y-%m-%d -d '3 day ago'`|grep -v `date +%Y-%m-%d -d '4 day ago'`|grep -v `date +%Y-%m-%d -d '5 day ago'`|awk '{print $2}' | xargs -n 1 -t /opt/ec2-api-tools-1.6.8.0/bin/ec2-delete-snapshot --region $region \n" >> /tmp/SnapShot_detail

/opt/ec2-api-tools-1.6.8.0/bin/ec2-describe-snapshots --region $region |grep $vol_id|sort -k 5|grep -v `date +%Y-%m-%d`|grep -v `date +%Y-%m-%d -d '1 day ago'`|grep -v `date +%Y-%m-%d -d '2 day ago'`|grep -v `date +%Y-%m-%d -d '3 day ago'`|grep -v `date +%Y-%m-%d -d '4 day ago'`|grep -v `date +%Y-%m-%d -d '5 day ago'`|awk '{print $2}' | xargs -n 1 -t /opt/ec2-api-tools-1.6.8.0/bin/ec2-delete-snapshot --region $region >> /tmp/SnapShot_detail


mail -s "$vm_id InstanceID - $ins_id IP - $ip VolumeID $vol_id SnapShot Created" $Email </tmp/SnapShot_detail
rm -rf /tmp/SnapShot_detail
