#!/bin/bash

case $1 in

sheppaasuserkey)

	rm /home/paasuser/.ssh/authorized_keys
	cp /home/paasadmin/sshkey/paasuser.pub  /home/paasuser/.ssh/authorized_keys
	chmod 600 /home/paasuser/.ssh/authorized_keys
	chown paasuser.paasuser /home/paasuser/.ssh/authorized_keys
	;;

sheppaasuseratr)
	chattr +AacDdijsSu /home/paasadmin/agent
	chattr +AacDdijsSu /home/paasadmin/.bashrc
        chattr +AacDdijsSu /home/paasadmin/.profile
        chattr +AacDdijsSu /home/paasadmin/process_check_gpaas.sh
        chattr +AacDdijsSu /home/paasadmin/cronjob
	;;
esac
