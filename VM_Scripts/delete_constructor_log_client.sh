#!/bin/bash

depId=$1

sed -i '/'$depId'/d' /etc/httpd/conf.d/proxy_http.conf

echo -e "\n`date`
depId=$1
sed -i '/'$depId'/d' /etc/httpd/conf.d/proxy_http.conf" >> /var/log/vmpath/apps-log_delete.log

/etc/init.d/httpd reload &>/dev/null
