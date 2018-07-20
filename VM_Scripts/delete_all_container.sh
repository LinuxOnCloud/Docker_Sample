#!/bin/bash
# This is some secure program that uses security.

VALID_PASSWORD="acb@example" #this is our password.



/usr/bin/lxc-list |/usr/bin/awk '{print $1}'> /root/lxclist
/bin/sed -i '/RUNNING/d' /root/lxclist
/bin/sed -i '/FROZEN/d' /root/lxclist
/bin/sed -i '/STOPPED/d' /root/lxclist
/bin/sed -i '/appwarp_server/d' /root/lxclist
/bin/sed -i '/compoundjs/d' /root/lxclist
/bin/sed -i '/api_server/d' /root/lxclist
/bin/sed -i '/hq_server/d' /root/lxclist
/bin/sed -i '/stand_alone/d' /root/lxclist
/bin/sed -i '/redis26/d' /root/lxclist
/bin/sed -i '/redis28/d' /root/lxclist
/bin/sed -i '/newredis/d' /root/lxclist
/bin/sed -i '/postgresql91/d' /root/lxclist
/bin/sed -i '/mysql55/d' /root/lxclist
/bin/sed -i '/mysql55_api/d' /root/lxclist
/bin/sed -i '/mongodb24/d' /root/lxclist
/bin/sed -i '/mongodb24_api/d' /root/lxclist
/bin/sed -i '/couchdb101/d' /root/lxclist
/bin/sed -i '/java16_tomcat60/d' /root/lxclist
/bin/sed -i '/java17_tomcat70/d' /root/lxclist
/bin/sed -i '/php53_apache22/d' /root/lxclist
/bin/sed -i '/php55_apache24/d' /root/lxclist
/bin/sed -i '/rails40_passenger40/d' /root/lxclist
/bin/sed -i '/ruby20_passenger40/d' /root/lxclist
/bin/sed -i '/ruby20_unicorn47/d' /root/lxclist
/bin/sed -i '/ruby20_unicorn47_test/d' /root/lxclist
/bin/sed -i '/ruby20_thin16/d' /root/lxclist
/bin/sed -i '/sinatra14_passenger40/d' /root/lxclist
/bin/sed -i '/zip_builder/d' /root/lxclist
/bin/sed -i '/java7_builder/d' /root/lxclist
/bin/sed -i '/java6_builder/d' /root/lxclist
/bin/sed -i '/java7_sa/d' /root/lxclist
/bin/sed -i '/php55_sa/d' /root/lxclist
/bin/sed -i '/ruby20_sa/d' /root/lxclist
/bin/sed -i '/wordpress37_php55_apache24/d' /root/lxclist
/bin/sed -i '/nodejs01022/d' /root/lxclist
/bin/sed -i '/python27/d' /root/lxclist
/bin/sed -i '/golang11/d' /root/lxclist
/bin/sed -i '/app4rohit/d' /root/lxclist
/bin/sed -i '/kbhdshdfhwadshfgch/d' /root/lxclist
/bin/sed -i '/test_ruby/d' /root/lxclist
/bin/sed -i '/go13_nginx16/d' /root/lxclist
/bin/sed -i '/go_for_revel/d' /root/lxclist
/bin/sed -i '/app_promo/d' /root/lxclist
/bin/sed -i '/ha_proxy/d' /root/lxclist
/bin/sed -i '/jenkins1589_java7_tomcat7/d' /root/lxclist

/usr/bin/tr '\n' ' ' < /root/lxclist >/root/123
d=`/bin/cat /root/123`
echo "d=$d"

echo "Please enter the password : "
read -s PASSWORD

if [ "$PASSWORD" == "$VALID_PASSWORD" ]; then
        echo  "You have access!"


for i in $d

do

/bin/echo "$i container delete"
/vmpath/sbin/app42_delete $i

done
rm -rf /root/123
rm -rf /root/lxclist

else
        echo "ACCESS DENIED!"
fi

