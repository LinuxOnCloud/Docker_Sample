#!/bin/bash

if [ ! -d /var/log/vmpath ]; then
	mkdir -p /var/log/vmpath
fi

echo -e "\n`date`" >> /var/log/vmpath/dedicate.log


case $2 in

usages)
	echo "ssh -i /root/.ssh/dedicated-appkey -t paasadmin@$1 /home/paasadmin/agent $2" >>/var/log/vmpath/dedicate.log
	ssh -i /root/.ssh/dedicated-appkey -t paasadmin@$1 /home/paasadmin/agent $2 2>&1 |tee -a /var/log/vmpath/dedicate.log
	;;
scp)
	echo "mkdir -p $4" 2>&1 |tee -a /var/log/vmpath/dedicate.log
	mkdir -p $4 2>&1 |tee -a /var/log/vmpath/dedicate.log
	echo "scp -i /root/.ssh/dedicated-appkey -r paasadmin@$1:$3 $4 2>&1" |tee -a /var/log/vmpath/dedicate.log
	scp -i /root/.ssh/dedicated-appkey -r paasadmin@$1:$3 $4 2>&1 |tee -a /var/log/vmpath/dedicate.log
	d=`ls $4`
	if [ -f $4/$d ]; then
		echo '{"code":5000,"success":"true","message":"Files Copy Successfully","appBackupPath":"'$4/$d'"}' 2>&1 |tee -a /var/log/vmpath/dedicate.log
	else
		echo '{"success":"false","code":9000,"message":"Files Copy Failed"}' 2>&1 |tee -a /var/log/vmpath/dedicate.log
	fi
	;;

scp_delete)
	if [ -d "$1" ]; then
		echo "rm -rf $1" 2>&1 |tee -a /var/log/vmpath/dedicate.log
		rm -rf $1 2>&1 |tee -a /var/log/vmpath/dedicate.log
		if [ $? -eq 0 ]; then
        		echo '{"code":5000,"success":"true","message":"File/Folder Deleted Successfully"}' 2>&1 |tee -a /var/log/vmpath/dedicate.log
       		else
    			echo '{"success":"false","code":9001,"message":"File/Folder Deleted Failed"}' 2>&1 |tee -a /var/log/vmpath/dedicate.log
		fi
	else
		echo '{"success":"false","code":9002,"message":"'$1' : No such file or directory"}' 2>&1 |tee -a /var/log/vmpath/dedicate.log
	fi;;


*)
	echo "ssh -i /root/.ssh/dedicated-appkey  paasadmin@$1 /home/paasadmin/agent $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}" >>/var/log/vmpath/dedicate.log
	ssh -i /root/.ssh/dedicated-appkey  paasadmin@$1 /home/paasadmin/agent $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52} 2>&1 |tee -a /var/log/vmpath/dedicate.log
	;;
esac
