#!/bin/bash

lxc_path=/var/lib/lxc
depId=$1
found_depId=`grep "$depId" /etc/apache2/sites-available/default|grep "Alias"|cut -d"/" -f2`



if [ -z "$found_depId" ]; then
    echo "'$depId' does not found in apache"
    exit 1
fi


sed -i '/Alias \/'$depId'/,+11 d' /etc/apache2/sites-available/default

sed -i '/Alias \/'$depId'/,+11 d' /opt/iptab/apache2

/etc/init.d/apache2 reload &>/dev/null

NatIP=`traceroute google.com|head -2|tail -1|cut -d'(' -f2|cut -d')' -f1`

if [ -z "$NatIP" ]; then
        NatIP="172.16.0.39"
fi

ssh -i /root/.ssh/id_rsa root@$NatIP /vmpath/sbin/delete_constructor_log_client $depId 
