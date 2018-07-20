#!/bin/bash

#$1 = case name
#$2 = sso domain name
#$3 = admin passwd
#$4 = vra public ip (loopback enable)
#$5 = vra domain name
#$6 = sso vm root passwd

# start sso function
ssostart() {
	sudo /etc/init.d/vmware-stsd start
}

# stop sso function
ssostop() {
	sudo /etc/init.d/vmware-stsd stop
}



case $1 in

# sso start case
start)
                state=`sudo netstat -npl|grep java|grep 7444 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                echo "state = $state"
                if [ -n "$state" ]; then
                        echo '{"code":5000,"success":"true", "message":"SSO Server Already Started"}'
                else
			ssostop
			sleep 30
                        ssostart
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true", "message":"SSO Server Started Successfully"}'
                        else
                                echo '{"success":"false", "code":9202,"message":"SSO Server Could Not Be Started"}'
                        fi
                fi;;

# sso stop case
stop)
                state=`sudo netstat -npl|grep java|grep 7444 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                echo "state = $state"
                if [ -z "$state" ]; then
                        echo '{"code":5000,"success":"true", "message":"SSO Server already Stopped"}'
                else
                        ssostop
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true", "message":"SSO Server Stopped Successfully"}'
                        else
                                echo '{"success":"false","code":9203, "message":"SSO Server Could Not Be Stopped"}'
                        fi
                fi;;


configuresso)
SSO_DOMAIN=$2
ADMIN_PASSWD=$3
VRCS_IP=$4
VRCS_DOMAIN=$5
SSO_ROOT_PASSWD=$6
	host=`hostname`
	if [ "$host" != $SSO_DOMAIN ]; then
		ip=`ip \r|tail -1|rev|awk '{print $1}'|rev`
		sudo chmod 777 /etc/hosts
		echo "$ip $SSO_DOMAIN" >> /etc/hosts
		echo "$VRCS_IP $VRCS_DOMAIN" >> /etc/hosts
		sudo chmod 644 /etc/hosts
		hostname $SSO_DOMAIN && sudo hostname $SSO_DOMAIN
	else
		sudo chmod 777 /etc/hosts
		echo "$VRCS_IP $VRCS_DOMAIN" >> /etc/hosts
                sudo chmod 644 /etc/hosts
	fi
	sudo /usr/lib/vmware-identity-va-mgmt/firstboot/vmware-identity-va-firstboot.sh --domain vsphere.local --password $ADMIN_PASSWD
	if [ $? -eq 0 ]; then
		sudo passwd root <<EOF
$SSO_ROOT_PASSWD
$SSO_ROOT_PASSWD
EOF
	if [ $? -eq 0 ]; then
		echo '{"code":5000,"success":"true", "message":"SSO Configure Successfully"}'
	else
		echo '{"success":"false", "code":9202,"message":"SSO Root User Password Could Not Be Configured"}'
	fi

	
 else
	echo '{"success":"false", "code":9202,"message":"SSO Could Not Be Configured"}'
fi;;		


resetrootpasswd)
SSO_ROOT_PASSWD=$2

	sudo passwd root <<EOF
$SSO_ROOT_PASSWD
$SSO_ROOT_PASSWD
EOF
        if [ $? -eq 0 ]; then
                echo '{"code":5000,"success":"true", "message":"SSO Root User Password Reset Successfully"}'
        else
                echo '{"success":"false", "code":9202,"message":"SSO Root User Password Could Not Be Configured"}'
        fi;;



esac
