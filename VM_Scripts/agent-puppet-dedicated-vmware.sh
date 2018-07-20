#!/bin/bash

HOME=/home/paasadmin


#sudo iptables -t nat -F

#sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

# start tomcat function
puppetstart() {
	/etc/init.d/puppetmaster start
}

# stop tomcat function
tomcatstop() {
	/etc/init.d/puppetmaster stop
}


case $1 in

cmd)		
		 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} 		${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}
		if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
			echo '{"success":"false", "code":9201,"message":"Command Execution Failed"}'
                fi;;

# webserver start case
start)
		state=`sudo netstat -npl|grep ruby|grep 8140 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		echo "state = $state"
		if [ -n "$state" ]; then  		
			echo '{"code":5000,"success":"true", "message":"Puppet-Master Already Started"}'
          	else
			puppetstart 
			if [ $? -eq 0 ]; then
				crontab -u paasadmin $HOME/cronjob
				echo '{"code":5000,"success":"true", "message":"Puppet-Master Started Successfully"}'
			else
				echo '{"success":"false", "code":9202,"message":"Puppet-Master Could Not Be Started"}'
			fi
		fi;;

# webserver stop case
stop)
		state=`sudo netstat -npl|grep ruby|grep 8140 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		echo "state = $state"
   		if [ -z "$state" ]; then
			echo '{"code":5000,"success":"true", "message":"Puppet-Master already Stopped"}'
		else
			crontab -r
			tomcatstop
			if [ $? -eq 0 ]; then
            			echo '{"code":5000,"success":"true", "message":"Puppet-Master Stopped Successfully"}'
          		else
          			echo '{"success":"false","code":9203, "message":"Puppet-Master Could Not Be Stopped"}'
          		fi
		fi;;

		
createkey)

		if [ ! -d $HOME/sshkey ]; then
        		mkdir -p $HOME/sshkey
		fi

        	/usr/bin/ssh-keygen -t rsa -f $HOME/sshkey/paasuser -N ""
		sudo /sbin/katr sheppaasuserkey
	        mv $HOME/sshkey/paasuser $HOME/sshkey/paasuser.pem
        	rm $HOME/sshkey/paasuser.pub
		
		if [ ! -z /home/paasuser/.ssh/authorized_keys ]; then
			 echo '{"code":5000,"success":"true","message":"PaaSUser SSH key Created","path":"'$HOME/sshkey/paasuser.pem'"}'
                else
			echo '{"success":"false","code":9209,"message":"PaaSUser SSH key Could Not Be Created"}'	
		fi;;


setup)
                logval=`grep "tomcat" /etc/apache2/sites-available/default|tail -1|cut -d"/" -f5|cut -d">" -f1`
                if [ "$logval" = "tomcat" ]; then
                        sudo sed -i 's/'tomcat'/'$2'/g' /etc/apache2/sites-available/default
                        ln -sf /var/log/puppet $HOME/logging/$2
                        if [ -L $HOME/logging/$2 ]; then
                                sudo /etc/init.d/apache2 restart
                                echo '{"code":5000,"success":"true","message":"LOG Link Created, Setup is Successfully"}'
                        else
                                echo '{"success":"false","code":9210,"message":"LOG Link Could Not Be Create, Setup is Failed"}'
                        fi
                else
                        echo '{"success":"false","code":9211,"message":"LOG Value Could Not Be Match in Apache Server, Setup is Failed"}'
                fi;;

addcronjob)
        	crontab -u paasadmin $HOME/cronjob
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Added Successfully"}'
	        else
        	        echo '{"success":"false","code":9212,"message":"CronJob Could Not Be Added"}'
	        fi;;

deletecronjob)
        	crontab -r
	        if [ $? -eq 0 ]; then
        	        echo '{"code":5000,"success":"true","message":"CronJob Deleted Successfully"}'
	        else
        	        echo '{"success":"false","code":9213,"message":"CronJob Could Not Be Deleted"}'
	        fi;;

usages)
                mem=`free -m |grep "Mem"|awk '{print $3}'`
                cpu=`top -bn1 |grep "Cpu"|awk '{print $2}'|cut -d"%" -f1`
                echo '{"code":5000,"success":"true","message":"Current Resorce Usages In '$containername'","memory":"'$mem'","cpu":"'$cpu'"}'
                ;;

reset_htpasswd)
                htpasswd -bc $HOME/htpasswd $2 $3
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true","message":"Http Auth Reset Successfully"}'
                else
                        echo '{"success":"false","code":9313,"message":"Http Auth Not Be Reset"}'
                fi;;

addsshkey)

        wget --no-check-certificate --directory-prefix=$HOME/download $2
        if [ $? -eq 0 ]; then
                fileWithExt=${2##*/}
                sudo cp $HOME/download/$fileWithExt  /home/paasuser/.ssh/authorized_keys
                sudo chmod 600 /home/paasuser/.ssh/authorized_keys
                sudo chown paasuser.paasuser /home/paasuser/.ssh/authorized_keys
                rm -rf $HOME/download/
                echo '{"code":5000,"success":"true", "message":"SSH Key Added Successfully"}'
        else
                echo '{"success":"false", "code":9202,"message":"SSH Key Download Failed"}'
                rm -rf $HOME/download/
        fi;;

addmanifests)

        wget --no-check-certificate --directory-prefix=$HOME/download $2
        if [ $? -eq 0 ]; then
                fileWithExt=${2##*/}
                sudo cp $HOME/download/$fileWithExt  /etc/puppet/manifests/.
                sudo chmod 644 /etc/puppet/manifests/$fileWithExt
                sudo chown root.root /etc/puppet/manifests/$fileWithExt
                rm -rf $HOME/download/
                echo '{"code":5000,"success":"true", "message":"Manifests File Added Successfully"}'
        else
                echo '{"success":"false", "code":9202,"message":"Manifests File Download Failed"}'
                rm -rf $HOME/download/
        fi;;

nodesign)
	sudo /usr/sbin/puppetca sign $2 > $HOME/rslt
	rslt=`cat $HOME/rslt|head -1|awk '{print $2}'`
	echo "Sign Signature = $rslt"
	if [ "Signed" == $rslt ]; then
		sudo /vmpath/sbin/addhost $3 $2
                echo '{"code":5000,"success":"true", "message":"Node Sing Successfully"}'
        else
                echo '{"success":"false", "code":9202,"message":"Node Sing Failed"}'
        fi;;
	


		
*)
                echo 'Usage: {cmd|start|stop|deploy|createkey|setup}'
		echo '{"success":"false", "code":9214,"message":"Invalid Command"}'
                ;;
esac
