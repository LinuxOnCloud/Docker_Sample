#!/bin/bash

# set variables 
old_container=$1
new_container=$2
vgname=lxc
memory=$3
swap=$4
cpu_share=$5
disk_size=$6
cpuset=$7
lxc_path=/var/lib/lxc
fstype=ext4
rootdev=/dev/$vgname/$new_container
heapmem=$8
vm_port=$9
mxconn=${10}
port=8081
port_check=1

# Print date
dater() {
	d=`/bin/date`
	/bin/echo "######################## $d ###########################"
}

# rolling back activities ( run app42_delete.sh ) and destroy lxc container
cleanup() {
        /vmpath/sbin/app42_cleanup $new_container
        exit 1
}
trap cleanup SIGHUP SIGINT SIGTERM


## create clone via lxc-clone script
dater
/bin/echo "Cloning Start"

/usr/bin/lxc-clone -o $old_container -n $new_container
if [ $? -ne 0 ]; then
	/bin/echo '{"success":"false","code":7101,"message":"Error In Lxc-Clone Script"}'
        exit 1
fi

dater
/bin/echo "lxc-clone script work is over"

## rename new container for lvm creation original container name

/bin/mv $lxc_path/$new_container $lxc_path/$new_container-1

##create dir for new container name

/bin/mkdir -p  $lxc_path/$new_container


##create lvm partition for lxc container
# if any problem with creation of lvm partition call "cleanup" and remove container

/sbin/lvcreate -L $disk_size -n $new_container $vgname
if [ $? -ne 0 ]; then
	/bin/echo '{"success":"false","code":7102,"message":"LVM Could Not Be Created"}'
	cleanup
        exit 1
fi
#        udevadm settle

# format lvm partition
# if any problem with formating of lvm partition call "cleanup" and remove container

/sbin/mkfs -t $fstype $rootdev
if [ $? -ne 0 ]; then
	/bin/echo '{"success":"false","code":7103,"message":"LVM Could Not Be Formatted"}'
        cleanup
        exit 1
fi
        /bin/mount -t $fstype $rootdev $lxc_path/$new_container
        /bin/echo "$rootdev  $lxc_path/$new_container  $fstype  defaults  0 0" >> /etc/fstab
        /bin/echo "$rootdev  $lxc_path/$new_container  $fstype  defaults  0 0" >> /opt/iptab/mounttab

## moving container data to lvm partition
dater
/bin/echo "Move clone data in lvm Partition"

/bin/mv $lxc_path/$new_container-1/* $lxc_path/$new_container/
/bin/rm -rf $lxc_path/$new_container-1


##update new container according to "vmpath"
dater
/bin/echo "update lxc config"


# create symbolic link new container for auto startup container
/bin/ln -s $lxc_path/$new_container/config /etc/lxc/auto/$new_container


# set cpu share
/bin/sed -i '/lxc.cgroup.cpu.shares/d' $lxc_path/$new_container/config
	/bin/echo "lxc.cgroup.cpu.shares = $cpu_share" >> $lxc_path/$new_container/config

# set cpu
if [ -z "$cpuset" ] || [ $cpuset = "null" ]; then
        cat /proc/cpuinfo |grep  processor |awk '{print $3}' >/tmp/$new_container
        cpuset=`tail -1 /tmp/$new_container`
        if [ "$cpuset" -gt "1" ]; then
                echo "cpuinfo=$cpuset"
                /bin/sed -i '/lxc.cgroup.cpuset.cpus/d' $lxc_path/$new_container/config
                /bin/echo "lxc.cgroup.cpuset.cpus = 1-$cpuset" >> $lxc_path/$new_container/config
		rm -rf /tmp/$new_container
        else
		if [ ! -z "$cpuset" ]; then
	                echo "cpuinfo1=$cpuset"
        	        /bin/sed -i '/lxc.cgroup.cpuset.cpus/d' $lxc_path/$new_container/config
                	/bin/echo "lxc.cgroup.cpuset.cpus = $cpuset" >> $lxc_path/$new_container/config
			rm -rf /tmp/$new_container
		else
			cpuset=0
			echo "cpuinfo2=$cpuset"
                        /bin/sed -i '/lxc.cgroup.cpuset.cpus/d' $lxc_path/$new_container/config
                        /bin/echo "lxc.cgroup.cpuset.cpus = $cpuset" >> $lxc_path/$new_container/config
                        rm -rf /tmp/$new_container
		fi
        fi
else
        echo "cpuset=$cpuset"
        /bin/sed -i '/lxc.cgroup.cpuset.cpus/d' $lxc_path/$new_container/config
        /bin/echo "lxc.cgroup.cpuset.cpus = $cpuset" >> $lxc_path/$new_container/config
fi


if [ -z "$heapmem" ] || [ $heapmem = "null" ]; then
	echo "heap memory null"
else
        /bin/echo $heapmem >> $lxc_path/$new_container/rootfs/opt/tomcat/bin/setenv.sh
	/bin/chmod +x $lxc_path/$new_container/rootfs/opt/tomcat/bin/setenv.sh
	/bin/chown 1001.1002 $lxc_path/$new_container/rootfs/opt/tomcat/bin/setenv.sh
	echo heap memory = $heapmem
fi



# set memory
/bin/sed -i '/lxc.cgroup.memory.limit_in_bytes/d' $lxc_path/$new_container/config
	/bin/echo "lxc.cgroup.memory.limit_in_bytes = $memory" >> $lxc_path/$new_container/config

# set swap memory
/bin/sed -i '/lxc.cgroup.memory.memsw.limit_in_bytes/d' $lxc_path/$new_container/config
	/bin/echo "lxc.cgroup.memory.memsw.limit_in_bytes = $swap" >> $lxc_path/$new_container/config

#update hostname on sudo file
/bin/sed -ie 's/'$old_container'/'$new_container'/g' $lxc_path/$new_container/rootfs/etc/sudoers


# copy base vm ssh key to new container
cp -arf /root/.ssh/id_rsa.pub $lxc_path/$new_container/rootfs/root/.ssh/authorized_keys
/bin/cat /dev/null > /root/.ssh/known_hosts


# set No of Connetion in service

if [ -z "$mxconn" ] || [ $mxconn = "null" ]; then
        echo "conn null not present"
else

case $old_container in

couchdb101)     /bin/sed -ie 's/max_connections = 2048/max_connections = '$mxconn'/g'   $lxc_path/$new_container/rootfs/etc/couchdb/default.ini ;;
mongodb24)      /bin/sed -ie 's/maxConns = 100/maxConns = '$mxconn'/g'                   $lxc_path/$new_container/rootfs/etc/mongodb.conf ;;
mysql55)        /bin/sed -ie 's/max_connections        = 100/max_connections        = '$mxconn'/g'  $lxc_path/$new_container/rootfs/etc/mysql/my.cnf ;;
postgresql91)   /bin/sed -ie 's/max_connections = 100/max_connections = '$mxconn'/g'    $lxc_path/$new_container/rootfs/etc/postgresql/9.1/main/postgresql.conf ;;

esac
fi

dater

/bin/echo " start lxc"
# start container
/usr/bin/lxc-start -n $new_container -d

/bin/sleep 30


# confirm container has started properly if not, then cleanup
count=1
cn_start=`/bin/grep $new_container /var/lib/misc/dnsmasq.leases|/usr/bin/awk '{print $4}'`

if [ -z "$cn_start" ]; then
        cn_start=null
else
        cn_start=$cn_start
fi

/bin/echo $cn_start

while [ $new_container != $cn_start ]; do
        /bin/echo $count
        if [ $count -lt 17 ]; then
                /bin/echo "IP Not Assign By DHCP Server Please Wait Some Time"
                sleep 3
                cn_start=`/bin/grep $new_container /var/lib/misc/dnsmasq.leases|/usr/bin/awk '{print $4}'`
                if [ -z $cn_start ]; then
                        cn_start=null
                fi
                count=$((count+1))
        else
		/bin/echo '{"success":"false","code":7104,"message":"DHCP Could Not Assign IP Address To Container "}'
                cleanup
                exit
        fi
done

# check ip for new container
container_ip=`/bin/grep $new_container /var/lib/misc/dnsmasq.leases|awk '{print $3}'`
container_port=`cat $lxc_path/$old_container/rootfs/root/container_port`

# set ip to config file in new container
/bin/sed -i '/lxc.network.ipv4/d' $lxc_path/$new_container/config
	/bin/echo "lxc.network.ipv4 = $container_ip/24" >> $lxc_path/$new_container/config

# check base vm ip
vm_ip=`/sbin/ip \r|/bin/grep eth0|/bin/grep src|/usr/bin/awk '{print $9}'`


# finding new free port on vm
if [ -z "$vm_port" ]; then
while [ $port_check -ne $port ]; do
opt_port=`/bin/grep -ir "$port" /opt/iptab/iptables.sh|/usr/bin/awk '{print $13}'|/usr/bin/sort -n`
/bin/echo "chcek port in iptable = $opt_port"
match=`/bin/echo $opt_port|/usr/bin/tail -1|/usr/bin/awk '{print $1}'`
/bin/echo "port tail = $match"
                if [ -z "$match" ]; then
		match=8080
		/bin/echo "if iptable is blank put = $match"

                if [ "$port" -eq "$match" ]; then
			port=$((port+1))
                        vm_port=$port
                        /bin/echo "if up true case vm_port=$vm_port"
                        /bin/echo "if up true case match=$match"
                else
			vm_port=$port
                        port_check=$vm_port
                        /bin/echo "if up false case port_check=$port_check"
                        /bin/echo "if up false case VM_PORT=$vm_port"
                fi
else

		if [ "$port" -eq "$match" ]; then
			port=$((port+1))
                        vm_port=$port
                        /bin/echo "if down true case vm_port=$vm_port"
                        /bin/echo "if down true case match=$match"
                else
			vm_port=$port
                        port_check=$vm_port
                        /bin/echo "if down false case port_check=$port_check"
                        /bin/echo "if down false case VM_PORT=$vm_port"
                fi
fi
done
fi


# set iptable on vm for request redirection to container
/sbin/iptables -t nat -I PREROUTING -p tcp -d $vm_ip -j DNAT --dport $vm_port --to-destination $container_ip:$container_port

        /sbin/iptables-save >/etc/iptables.rule

        /bin/echo "/sbin/iptables -t nat -I PREROUTING -p tcp -d $vm_ip -j DNAT --dport $vm_port --to-destination $container_ip:$container_port" >>/opt/iptab/iptables.sh

# update user and group
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /usr/sbin/usermod -l $new_container $old_container
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /usr/sbin/groupmod -n $new_container $old_container
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /bin/mv /home/$old_container /home/$new_container
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip /usr/sbin/usermod -d /home/$new_container $new_container
/bin/cp -arf  $lxc_path/$new_container/rootfs/root/.ssh $lxc_path/$new_container/rootfs/home/$new_container/
/usr/bin/ssh -i /root/.ssh/id_rsa root@$container_ip chown -R $new_container.$new_container /home/$new_container


/bin/bash /vmpath/sbin/startup_ruby_templ.sh $old_container $new_container

/vmpath/sbin/config_constructor_log $new_container $vm_ip


local_host=`/usr/bin/ec2metadata --local-hostname`

echo -e "\n`date` Temptale = $old_container , Container = $new_container , Package { memory = $3 , swap = $4 , cpu_share = $5 , disk_size = $6 , cpuset = $7 , heapmem = $8 , vm_port = $9 , mxconn = ${10} } Iptable = /sbin/iptables -t nat -I PREROUTING -p tcp -d $vm_ip -j DNAT --dport $vm_port --to-destination $container_ip:$container_port Insert - 'lxc.cgroup.cpu.shares = $cpu_share >> $lxc_path/$new_container/config', 'lxc.cgroup.cpuset.cpus = $cpuset >> $lxc_path/$new_container/config', 'lxc.cgroup.memory.limit_in_bytes = $memory >> $lxc_path/$new_container/config', 'lxc.cgroup.memory.memsw.limit_in_bytes = $swap >> $lxc_path/$new_container/config', '$heapmem >> $lxc_path/$new_container/rootfs/opt/tomcat/bin/setenv.sh'\n"  >> /opt/iptab/clone.log
/bin/echo '{"code":5000,"success":"true", "message":"Container created successfully", "vm_ip":"'$local_host'", "vm_port":'$vm_port', "container_ip":"'$container_ip'", "container_port":'$container_port'}'
dater
