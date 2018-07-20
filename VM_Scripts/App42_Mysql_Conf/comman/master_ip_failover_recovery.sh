#!/bin/bash

if [ "$1" == "poiuytrewq" ]; then

mkdir -p /home/azureuser/Installationpkg/comman/mha


echo "#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Getopt::Long;

use Net::Ping;
use Switch;

my (\$command, \$ssh_user, \$orig_master_host, \$orig_master_ip, \$orig_master_port, \$new_master_host, \$new_master_ip, \$new_master_port, \$new_master_user, \$new_master_password);


GetOptions(
  'command=s'             => \\\$command,
  'ssh_user=s'            => \\\$ssh_user,
  'orig_master_host=s'    => \\\$orig_master_host,
  'orig_master_ip=s'      => \\\$orig_master_ip,
  'orig_master_port=i'    => \\\$orig_master_port,
  'new_master_host=s'     => \\\$new_master_host,
  'new_master_ip=s'       => \\\$new_master_ip,
  'new_master_port=i'     => \\\$new_master_port,
  'new_master_user=s'     => \\\$new_master_user,
  'new_master_password=s' => \\\$new_master_password,
);


my \$vip = '10.51.1.23/24';  # Virtual IP
my \$master_srv = '10.51.1.21';
my \$timeout = 5;
my \$key = \"1\";
my \$ssh_start_vip = \"sudo /sbin/ifconfig eth0:\$key \$vip\";
my \$ssh_stop_vip = \"sudo /sbin/ifconfig eth0:\$key down\";

exit &main();

sub main {

print \"\\n\\nIN SCRIPT TEST====\$ssh_stop_vip==\$ssh_start_vip===\\n\\n\";

if ( \$command eq \"stop\" || \$command eq \"stopssh\" ) {

    # \$orig_master_host, \$orig_master_ip, \$orig_master_port are passed.
    # If you manage master ip address at global catalog database,
    # invalidate orig_master_ip here.
    my \$exit_code = 1;
    eval {
        print \"Disabling the VIP on old master if the server is still UP: \$orig_master_host \\n\";
        my \$p=Net::Ping->new('icmp');
        &stop_vip() if \$p->ping(\$master_srv, \$timeout);
        \$p->close();
        \$exit_code = 0;
    };
    if (\$@) {
        warn \"Got Error: \$@\\n\";
        exit \$exit_code;
    }
    exit \$exit_code;
}
elsif ( \$command eq \"start\" ) {

    # all arguments are passed.
    # If you manage master ip address at global catalog database,
    # activate new_master_ip here.
    # You can also grant write access (create user, set read_only=0, etc) here.
my \$exit_code = 10;
    eval {
        print \"Enabling the VIP - \$vip on the new master - \$new_master_host \\n\";
        &start_vip();
        \$exit_code = 0;
    };
    if (\$@) {
        warn \$@;
        exit \$exit_code;
    }
    exit \$exit_code;
}
elsif ( \$command eq \"status\" ) {
    print \"Checking the Status of the script.. OK \\n\";
    #\`ssh \$ssh_user\\@\$new_master_host \\\" \$ssh_start_vip \\\"\`;
    exit 0;
}
else {
    &usage();
    exit 1;
}
}

# A simple system call that enable the VIP on the new master
sub start_vip() {
#    \`ssh \$ssh_user\\@\$new_master_host \\\" \$ssh_start_vip \\\"\`;
\`ifconfig eth0:\$key \$vip\`;
print \"Iptable Set \\n\";
#\`iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE\`;
#\`iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 3306 --to-destination 10.51.1.24:3306\`;
#\`ssh \$ssh_user\\@\$orig_master_host \\\" \$ssh_stop_vip \\\"\`;
#\`ssh -i /root/.ssh/id_rsa root@10.51.1.7 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE\`;
#\`ssh -i /root/.ssh/id_rsa root@10.51.1.7 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 3306 --to-destination 10.51.1.24:3306\`;
\`/app42RDS/sbin/recovery_iptables poiuytrewq &\`;
\`/app42RDS/sbin/mail_recover qwertyuiop &\`;
#
}
# A simple system call that disable the VIP on the old_master
sub stop_vip() {
print \"Iptable Flush \\n\";
#\`iptables -t nat -F\`;
#\`ssh \$ssh_user\\@\$orig_master_host \\\" \$ssh_stop_vip \\\"\`;
#\`/bin/bash /etc/mha/mail_recover.sh\`;
}

sub usage {
print
\"Usage: master_ip_failover --command=start|stop|stopssh|status --orig_master_host=host --orig_master_ip=ip --orig_master_port=port --new_master_host=host --new_master_ip=ip --new_master_port=port\\n\";
}" > /home/azureuser/Installationpkg/comman/mha/master_ip_failover_recovery

chmod 755 /home/azureuser/Installationpkg/comman/mha/master_ip_failover_recovery

else
        echo "You are not authourize person, Please leave now."
        exit
fi

