#!/bin/bash

if [ "$1" == "poiuytrewq" ]; then

cluster_name=`hostname|cut -d "-" -f1`

priv_ip=`ip \r|grep "scope link  src"|rev|awk '{print $1}'|rev`

echo "
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.

# PostgreSQL Allow IP's address
host    repmgr          repmgr     10.20.1.0/24     trust
host    replication     repmgr     10.20.1.0/24     trust
host    all         all  0.0.0.0/0     md5" > /home/azureuser/Installationpkg/comman-postgresql/pg_hba.conf

echo "failover=automatic
promote_command=/var/lib/pgsql/repmgr/promot.sh
follow_command='/usr/pgsql-9.6/bin/repmgr standby follow -f /etc/repmgr/repmgr.conf --log-to-file'
cluster=$cluster_name
node=1
node_name=`hostname`
use_replication_slots=1
conninfo='host=10.20.1.7 user=repmgr dbname=repmgr'
master_response_timeout=10
reconnect_attempts=3
reconnect_interval=10
pg_bindir=/usr/pgsql-9.6/bin/
service_start_command = /etc/init.d/postgresql-9.6 start
service_stop_command = /etc/init.d/postgresql-9.6 stop
service_restart_command = /etc/init.d/postgresql-9.6 restart
loglevel=NOTICE
logfacility=STDERR
logfile='/var/lib/pgsql/repmgr/repmgr.log'" >  /home/azureuser/Installationpkg/comman-postgresql/repmgr-master.conf

echo "failover=automatic
promote_command=/var/lib/pgsql/repmgr/promot.sh
follow_command='/usr/pgsql-9.6/bin/repmgr standby follow -f /etc/repmgr/repmgr.conf --log-to-file'
cluster=$cluster_name
node=2
node_name=`hostname`
use_replication_slots=1
conninfo='host=10.20.1.8 user=repmgr dbname=repmgr'
master_response_timeout=10
reconnect_attempts=3
reconnect_interval=10
pg_bindir=/usr/pgsql-9.6/bin/
service_start_command = /etc/init.d/postgresql-9.6 start
service_stop_command = /etc/init.d/postgresql-9.6 stop
service_restart_command = /etc/init.d/postgresql-9.6 restart
loglevel=NOTICE
logfacility=STDERR
logfile='/var/lib/pgsql/repmgr/repmgr.log'" >  /home/azureuser/Installationpkg/comman-postgresql/repmgr-standby.conf


echo "#!/bin/bash
echo \"Promoting Standby at \`date '+%Y-%m-%d %H:%M:%S'\`\"
repmgr -f /etc/repmgr/repmgr.conf standby promote

ssh -i \$HOME/.ssh/id_rsa root@10.20.1.5 iptables -t nat -F
ssh -i \$HOME/.ssh/id_rsa root@10.20.1.5 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ssh -i \$HOME/.ssh/id_rsa root@10.20.1.5 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 5432 --to-destination $priv_ip:5432
ssh -i \$HOME/.ssh/id_rsa root@10.20.1.5 /etc/init.d/iptables save
ssh -i \$HOME/.ssh/id_rsa root@10.20.1.6 iptables -t nat -F
ssh -i \$HOME/.ssh/id_rsa root@10.20.1.6 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ssh -i \$HOME/.ssh/id_rsa root@10.20.1.6 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 5432 --to-destination $priv_ip:5432
ssh -i \$HOME/.ssh/id_rsa root@10.20.1.6 /etc/init.d/iptables save

/app42RDS/sbin/mail qwertyuiop & " > /home/azureuser/Installationpkg/comman-postgresql/promot.sh


else
        echo "You are not authourize person, Please leave now."
        exit
fi

