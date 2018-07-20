#!/bin/bash
# get instance id and put aws.properties file
id=`/usr/bin/ec2metadata --instance-id`

/bin/echo "instance_id = $id" >/root/instance.properties

