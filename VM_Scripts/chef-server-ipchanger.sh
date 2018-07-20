#!/bin/bash

count=0

while [ $count -lt 2000 ]
#while true;
do
	nginz_old=`/bin/cat /var/opt/opscode/nginx/etc/nginx.conf |grep server_name|head -1|awk '{print $2}'`
        /bin/sed -ie 's/server_name '$nginz_old'/server_name '$1';/g' /var/opt/opscode/nginx/etc/nginx.conf
	/bin/sed -ie 's/listen 80;/listen 81;/g' /var/opt/opscode/nginx/etc/nginx.conf
	#echo $count
	count=`expr $count + 1`
done

