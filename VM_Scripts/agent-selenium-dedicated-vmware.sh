#!/bin/bash

HOME=/home/paasadmin

export JAVA_HOME="/opt/jdk1.7.0_21/"
export PATH=$PATH:$JAVA_HOME/bin

#sudo iptables -t nat -F

#sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

# start tomcat function
seleniumstart() {
	sudo /etc/init.d/xvfb start > /dev/null 2>&1
	sudo /etc/init.d/selenium start > /dev/null 2>&1
}

# stop tomcat function
seleniumstop() {
	sudo /etc/init.d/selenium stop
	sudo /etc/init.d/xvfb stop
}


case $1 in

cmd)
                 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}          ${31} ${32} ${33} ${34} ${35} ${36} ${37} ${38} ${39} ${40} ${41} ${42} ${43} ${44} ${45} ${46} ${47} ${48} ${49} ${50} ${51} ${52}
                if [ $? -eq 0 ]; then
                        echo '{"code":5000,"success":"true", "message":"Command Successfully Executed"}'
                else
                        echo '{"success":"false", "code":9201,"message":"Command Execution Failed"}'
                fi;;



# webserver start case
start)
                state=`sudo netstat -npl|grep java|grep 4444 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		state1=`sudo netstat -npl|grep Xvfb|grep 6099|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                echo "state = $state"
                if [ -n "$state" ] && [ -n "$state1" ]; then
                        echo '{"code":5000,"success":"true", "message":"Selenium Already Started"}'
                else
                        seleniumstart
                        if [ $? -eq 0 ]; then
                                crontab -u paasadmin $HOME/cronjob
                                echo '{"code":5000,"success":"true", "message":"Selenium Started Successfully"}'
                        else
                                echo '{"success":"false", "code":9202,"message":"Selenium Could Not Be Started"}'
                        fi
                fi;;

# webserver stop case
stop)
                state=`sudo netstat -npl|grep java|grep 4444 |head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
		state1=`sudo netstat -npl|grep Xvfb|grep 6099|head -1|cut -d'/' -f1|rev|awk '{print $1}'|rev`
                echo "state = $state"
                if [ -z "$state" ] && [ -z "$state1" ]; then
                        echo '{"code":5000,"success":"true", "message":"Selenium already Stopped"}'
                else
                        crontab -r
                        seleniumstop
                        if [ $? -eq 0 ]; then
                                echo '{"code":5000,"success":"true", "message":"Selenium Stopped Successfully"}'
                        else
                                echo '{"success":"false","code":9203, "message":"Selenium Could Not Be Stopped"}'
                        fi
                fi;;


setup)
#               mv $CATALINA_BASE/webapps/read_log.war $CATALINA_BASE/webapps/$2.war
                logval=`grep "tomcat" /etc/apache2/sites-available/default|tail -1|cut -d"/" -f5|cut -d">" -f1`
                if [ "$logval" = "tomcat" ]; then
                        sudo sed -i 's/'tomcat'/'$2'/g' /etc/apache2/sites-available/default
                        ln -sf /var/log/selenium $HOME/logging/$2
#                       sudo /sbin/katr sheppaasuseratr $2

                        if [ -L $HOME/logging/$2 ]; then
                                sudo /etc/init.d/apache2 restart
                                seleniumstart
                                crontab -u paasadmin $HOME/cronjob
                                echo '{"code":5000,"success":"true","message":"LOG Link Created, Setup is Successfully"}'
                        else
                                echo '{"success":"false","code":9210,"message":"LOG Link Could Not Be Create, Setup is Failed"}'
                        fi
                else
                        echo '{"success":"false","code":9211,"message":"LOG Value Could Not Be Match in Apache Server, Setup is Failed"}'
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
esac
