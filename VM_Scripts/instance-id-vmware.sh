#!/bin/bash
# get instance id and put aws.properties file
id=`hostname`

/bin/echo "instance_id = $id" >/root/instance.properties

