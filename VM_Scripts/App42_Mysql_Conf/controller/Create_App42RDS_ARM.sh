#!/bin/bash

user=`echo "$1" |tr -d '-'`

getent passwd $user
if [ $? -eq 0 ]; then
    echo "yes the user $user exists"
else
    /usr/sbin/useradd --shell /sbin/nologin $user
fi

/bin/su -s /bin/bash -c "/app42RDS/sbin/Create_App42RDS_org $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} '${13}' ${14}" $user
