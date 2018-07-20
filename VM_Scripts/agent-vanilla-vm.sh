#!/bin/bash

HOME=/home/paasadmin

case $1 in
addsshkey)

	mkdir -p $HOME/download
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

signnode)
	sudo sed -i 's/no/yes/g' /etc/default/puppet
	sudo chmod 777 /etc/hosts
	sudo echo "$2 $3" >>/etc/hosts
	sudo chmod 644 /etc/hosts
	sudo /etc/init.d/puppet restart
	if [ $? -eq 0 ]; then
		sudo puppetd --server $3 --waitforcert 60 --test >/dev/null 2>&1 &
		echo '{"code":5000,"success":"true", "message":"Puppet Node Signed Successfully"}'
	else
		echo '{"success":"false", "code":9202,"message":"Puppet Node Signed Failed"}'
	fi;;


esac


