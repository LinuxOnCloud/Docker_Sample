#!/bin/bash

root_path="/var/lib/lxc/$3/rootfs"

case $1 in

hard_backup)                
	case $2 in

	wordpress37_php55_apache24)

		cd $root_path/var/www && tar czf wordpress.tar.gz wordpress
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true","message":"Wordpress Hard Backup Created","appBackupPath":"'$root_path/var/www/wordpress.tar.gz'"}'
		else
			echo '{"success":"false","code":8900,"message":"Wordpress Hard Backup Could Not Be Created"}'
			rm -rf $root_path/var/www/wordpress.tar.gz
		fi;;
	esac;;

hard_restore)
	case $2 in

        wordpress37_php55_apache24)

		/vmpath/sbin/app42_agent_commander $3 stop >/dev/null
		mv $root_path/var/www/wordpress $root_path/var/www/wordpress.old
		wget --no-check-certificate --directory-prefix=/opt/download $4
	        fileWithExt=${4##*/}
        	echo "file=$fileWithExt"
		tar xvzf /opt/download/$fileWithExt -C $root_path/var/www/
        	if [ $? -eq 0 ]; then
                	echo '{"code":5000,"success":"true","message":"Wordpress Successfully Hard Restore"}'
			chown -R 33.1001 $root_path/var/www/
			/vmpath/sbin/app42_agent_commander $3 start >/dev/null
			rm /opt/download/$fileWithExt
	        else
			mv $root_path/var/www/wordpress.old $root_path/var/www/wordpress
			rm /opt/download/$fileWithExt
			/vmpath/sbin/app42_agent_commander $3 start >/dev/null
        	        echo '{"success":"false","code":8401,"message":"Wordpress Could Not Be Hard Restore"}'
	        fi;;
	esac;;

delete_backup)
	rm -rf $2 
	if [ $? -eq 0 ]; then
                echo '{"code":5000,"success":"true","message":"Wordpress Backup File Deleted Successfully"}'
        else
                echo '{"success":"false","code":8402,"message":"Wordpress Backup File Could Not Be Deleted"}'
        fi;;	

*)
                echo 'Usage: {hard_backup|hard_restore|delete_backup}'
                echo '{"success":"false", "code":8403,"message":"Invalid Command"}'
                ;;
esac
