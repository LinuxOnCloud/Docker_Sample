#!/bin/bash

user=`echo "$1" |tr -d '-'`

getent passwd $user
if [ $? -eq 0 ]; then
    echo "yes the user $user exists"
else
    /usr/sbin/useradd --shell /sbin/nologin $user
fi

/bin/su -s /bin/bash -c "/app42RDS/sbin/Delete_App42RDS_ARM_org $1 $2" $user
