#!/bin/bash

root_path="/var/lib/lxc/$3/rootfs"
db_path="var/lib"
db_name=$2
permission=`cat $root_path/etc/passwd 2>/dev/null|grep $db_name|head -1|cut -d':' -f3,4`
backup_path=$4

case $1 in

hard_backup)                
	/usr/bin/lxc-stop -n $3
	cd $root_path/$db_path && zip -r $3.zip $db_name && mv $3.zip /opt/hard_backups/
	if [ $? -eq 0 ]; then
		echo '{"code":5000,"success":"true","message":"'$db_name' Database Hard Backup Created","backupPath":"'/opt/hard_backups/$3.zip'"}'
	else
		echo '{"success":"false","code":8400,"message":"'$db_name' Database Hard Backup Could Not Be Created"}'
		rm -rf /opt/hard_backups/$3.zip
	fi;;

hard_restore)
        /usr/bin/lxc-stop -n $3
        cd $root_path/$db_path && rm -rf $db_name && unzip $backup_path -d $root_path/$db_path/
        if [ $? -eq 0 ]; then
                echo '{"code":5000,"success":"true","message":"'$db_name' Database Hard Restore Created"}'
		chown -R $permission $root_path/$db_path/$db_name
		/usr/bin/lxc-start -n $3 -d
        else
                echo '{"success":"false","code":8401,"message":"'$db_name' Database Hard Restore Could Not Be Created"}'
        fi;;

delete_backup)
	rm -rf $2 
	if [ $? -eq 0 ]; then
                echo '{"code":5000,"success":"true","message":"Backup File Deleted Successfully"}'
        else
                echo '{"success":"false","code":8402,"message":"Backup File Could Not Be Deleted"}'
        fi;;	

*)
                echo 'Usage: {hard_backup|hard_restore|delete_backup}'
                echo '{"success":"false", "code":8403,"message":"Invalid Command"}'
                ;;
esac
