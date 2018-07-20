#!/bin/bash

lxc_path=/var/lib/lxc
depId=$1
vmIP=$2


if [ ! -d "$lxc_path/$depId" ]; then
    echo "'$depId' does not exist"
    exit 1
fi

echo -e "\n`date`" >> /var/log/vmpath/$depId


sed -i '/<\/VirtualHost>/d' /etc/apache2/sites-available/default

sed -i '/<\/VirtualHost>/d' /opt/iptab/apache2


echo '	Alias /'$depId'/ "/var/lib/lxc/'$depId'/rootfs/opt/log/"
        <Directory /var/lib/lxc/'$depId'/rootfs/opt/log/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
		AuthType Basic
                AuthName "vmpath Logs Auth"
                AuthUserFile /var/lib/lxc/'$depId'/rootfs/opt/htpasswd
                Require valid-user
                Order allow,deny
                allow from all
        </Directory>

</VirtualHost>' |tee -a /etc/apache2/sites-available/default /var/log/vmpath/$depId

echo '  Alias /'$depId'/ "/var/lib/lxc/'$depId'/rootfs/opt/log/"
        <Directory /var/lib/lxc/'$depId'/rootfs/opt/log/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
		AuthType Basic
                AuthName "vmpath Logs Auth"
                AuthUserFile /var/lib/lxc/'$depId'/rootfs/opt/htpasswd
                Require valid-user
                Order allow,deny
                allow from all
        </Directory>

</VirtualHost>' >>/opt/iptab/apache2


/etc/init.d/apache2 reload &>/dev/null

#NatIP=`traceroute google.com|head -2|tail -1|cut -d'(' -f2|cut -d')' -f1`

#if [ -z "$NatIP" ]; then
	NatIP="172.16.3.4"
#fi

ssh -i /root/.ssh/id_rsa root@$NatIP /vmpath/sbin/config_constructor_log_client $depId $vmIP
 
