#!/bin/bash

lxc_path=/var/lib/lxc
depId=$1
user=$2
passwd=$3


if [ ! -d "$lxc_path/$depId" ]; then
    echo "'$depId' does not exist"
    exit 1
fi


htpasswd -bc $lxc_path/$depId/rootfs/opt/htpasswd $user $passwd

if [ $? -eq 0 ]; then
	echo '{"code":5000,"success":"true","message":"Http Auth Reset Successfully"}'
else
	echo '{"success":"false","code":9313,"message":"Http Auth Not Be Reset"}'
fi
