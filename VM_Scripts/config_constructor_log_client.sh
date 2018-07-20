#!/bin/bash

depId=$1
vmIP=$2

echo 'ProxyPass /'$depId'/ http://'$vmIP'/'$depId'/' >>/etc/httpd/conf.d/proxy_http.conf

echo -e "\n`date`
depId=$1
vmIP=$2
'ProxyPass /'$depId'/ http://'$vmIP'/'$depId'/'" >> /var/log/vmpath/apps-log.log

/etc/init.d/httpd reload &>/dev/null
