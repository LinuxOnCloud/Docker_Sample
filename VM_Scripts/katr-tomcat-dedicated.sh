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
        chattr +AacDdijsSu /home/paasadmin/.ssh/authorized_keys
        chattr -R +AacDdijsSu /home/paasadmin/java 2> /dev/null
        chattr -R +AacDdijsSu /home/paasadmin/tomcat
        chattr -R -AacDdijsSu /home/paasadmin/tomcat/logs
        chattr -R +u /home/paasadmin/tomcat/logs
        chattr -R -AacDdijsSu /home/paasadmin/tomcat/temp
        chattr -R -AacDdijsSu /home/paasadmin/tomcat/work
        chattr -R -AacDdijsSu /home/paasadmin/tomcat/webapps
        chattr -R +AacDdijsSu /home/paasadmin/tomcat/webapps/$2.war
	;;
esac
