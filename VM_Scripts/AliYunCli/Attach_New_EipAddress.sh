#!/bin/bash

instance_name=$2

Region=$1

if [ -z $Region ] || [ -z $instance_name ]; then
        echo "Usage: ./Attach_New_EipAddress <RegionId> <InstanceName>"
        exit 1
fi


aliyuncli ecs DescribeInstances --RegionId $Region --InstanceName "$instance_name" --filter Instances.Instance[*].EipAddress.AllocationId > /tmp/Old_Eip_id
if [ $? -eq 0 ]; then
        Old_Eip_id=`cat /tmp/Old_Eip_id|grep "eip-"|tr -d ' '|cut -d '"' -f2`
        if [ -z $Old_Eip_id ]; then
                echo "Eip Address Is Not Attached To The Instance"
                exit 1
        fi

else
        echo "Due To Some Error Eip Address Could Not Be Fetched"
        exit 1
fi


aliyuncli ecs DescribeInstances --RegionId $Region --InstanceName "$instance_name" --filter Instances.Instance[*].InstanceId > /tmp/instance_id
if [ $? -eq 0 ]; then
        instance_id=`cat /tmp/instance_id|grep "i-"|tr -d ' '|cut -d '"' -f2`
else
        echo "Due To Some Error Instance ID Could Not Be Fetched"
        exit 1
fi


aliyuncli ecs AllocateEipAddress --RegionId $Region --InternetChargeType PayByTraffic --filter AllocationId > /tmp/New_Eip_id
if [ $? -eq 0 ]; then
        New_Eip_id=`cat /tmp/New_Eip_id|cut -d '"' -f2`
else
        echo "Due To Some Error New Eip Address Could Not Be Allocated"
fi


aliyuncli ecs UnassociateEipAddress --RegionId $Region --InstanceId $instance_id --AllocationId $Old_Eip_id > /tmp/UnassociateEipAddress
if [ $? -eq 0 ]; then
        sleep 5
else
        echo "Due To Some Error Old Eip Address Could Not Be Unassociated"
        Chk_Old_Eip_id=`aliyuncli ecs DescribeInstances --RegionId $Region --InstanceName "$instance_name" --filter Instances.Instance[*].EipAddress.AllocationId||grep "eip-"|tr -d ' '|cut -d '"' -f2`
        if [ -z $Chk_Old_Eip_id ]; then
                aliyuncli ecs AssociateEipAddress --RegionId $Region --InstanceId $instance_id --AllocationId $Old_Eip_id > /tmp/UnassociateEipAddress.Failed.AssociateEipAddress
        fi
        exit 1
fi

aliyuncli ecs AssociateEipAddress --RegionId $Region --InstanceId $instance_id --AllocationId $New_Eip_id > /tmp/AssociateEipAddress
if [ $? -eq 0 ]; then
        sleep 2
else
        echo "Due To Some Error New Eip Address Could Not Be Associated, Associating Old Eip Address"
        aliyuncli ecs AssociateEipAddress --RegionId $Region --InstanceId $instance_id --AllocationId $Old_Eip_id /tmp/AssociateEipAddress.Failed.OldAssociateEipAddress
        aliyuncli ecs ReleaseEipAddress --RegionId $Region --AllocationId $New_Eip_id > /tmp/AssociateEipAddress.Failed.ReleaseEipAddress
        exit 1
fi

aliyuncli ecs ReleaseEipAddress --RegionId $Region --AllocationId $Old_Eip_id > /tmp/ReleaseEipAddress
if [ $? -eq 0 ]; then
        sleep 1
else
        aliyuncli ecs ReleaseEipAddress --RegionId $Region --AllocationId $Old_Eip_id > /tmp/ReleaseEipAddress.Try2
        echo "Due To Some Error Old Eip Address Could Not Be Released, Please Try To Release Old Eip Address From Portal"
fi


Public_IP=`aliyuncli ecs DescribeInstances --RegionId $Region --InstanceName "$instance_name" --filter Instances.Instance[*].EipAddress.IpAddress|grep -v "\["|grep -v "\]"|tr -d ' '|cut -d '"' -f2`

echo "New Eip Address = $Public_IP"
