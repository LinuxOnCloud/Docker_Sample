old_container=$1
new_container=$2
container_ip=$3
lxc_path=/var/lib/lxc

cp /root/.ssh/id_rsa.pub $lxc_path/$new_container/rootfs/root/.ssh/authorized_keys
#update hostname on sudo file
/bin/sed -ie 's/'$old_container'/'$new_container'/g' $lxc_path/$new_container/rootfs/etc/sudoers

# update user and group
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /usr/sbin/usermod -l $new_container $old_container
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /usr/sbin/groupmod -n $new_container $old_container
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /bin/mv /home/$old_container /home/$new_container
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /usr/sbin/usermod -d /home/$new_container $new_container

/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip chown -R $new_container.$new_container /home/$new_container

/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip passwd $new_container <<EOF
$new_container
$new_container
EOF 

echo "bye"
