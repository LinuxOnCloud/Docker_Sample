#!/bin/sh

/bin/ls -l /root/.ssh/id_rsa*
/bin/echo "home=root"

if [ $? = 0 ]; then 

	/bin/rm -rf /root/.ssh/id_rsa*
	/usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
else
	/usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
fi

/usr/bin/lxc-list |/usr/bin/awk '{print $1}'> /root/lxclist
/bin/sed -i '/RUNNING/d' /root/lxclist
/bin/sed -i '/FROZEN/d' /root/lxclist
/bin/sed -i '/STOPPED/d' /root/lxclist
/usr/bin/tr '\n' ' ' < /root/lxclist >/root/123
d=`/bin/cat root/123`

for i in $d
do
   /bin/echo "Copying ssh key on $i container"
/bin/cat /root/.ssh/id_rsa.pub >> /var/lib/lxc/$i/rootfs/root/.ssh/authorized_keys
/bin/cat /root/.ssh/id_rsa.pub >> /var/lib/lxc/$i/rootfs/home/$i/.ssh/authorized_keys

done
