#!/bin/bash
dep_id=$2

export JAVA_HOME="/opt/java/"
export GRAILS_HOME="/opt/grails/"
export PATH=$PATH:$GRAILS_HOME/bin:$JAVA_HOME/bin

case $1 in

create_java_war)

	mkdir -p $HOME/$dep_id
	cd  $HOME/$dep_id && git clone $3 > $HOME/file_$dep_id
	if [ $? = 0 ]; then
		dir=`cat $HOME/file_$dep_id |cut -d"'" -f2`
		if [ -f $HOME/$dep_id/$dir/pom.xml ]; then
			cd $HOME/$dep_id/$dir/ && mvn clean
			mvn install
			if [ $? = 0 ]; then
				mkdir -p $HOME/war_$dep_id
				mv $HOME/$dep_id/$dir/target/*.war $HOME/war_$dep_id/ROOT.war
				rm -rf $HOME/$dep_id $HOME/file_$dep_id
				echo '{"code":5000,"success":"true","message":"Java WAR File Created Successfully","path":"'$HOME/war_$dep_id/ROOT.war'"}'
			else
				rm -rf $HOME/$dep_id $HOME/file_$dep_id
				echo '{"success":"false","code":8301,"message":"Error In Creating Binary"}'
			fi
		
		else
			rm -rf $HOME/$dep_id $HOME/file_$dep_id
			echo '{"success":"false","code":8302,"message":"POM.xml Does Not Exist"}'
		fi
	else
		rm -rf $HOME/$dep_id $HOME/file_$dep_id
		echo '{"success":"false","code":8303,"message":"Error In Cloning GIT Repository"}'
	fi;;

create_grails_war)

        mkdir -p $HOME/$dep_id
        cd  $HOME/$dep_id && git clone $3 > $HOME/file_$dep_id
        if [ $? = 0 ]; then
                dir=`cat $HOME/file_$dep_id |cut -d"'" -f2`
		if [ ! -d $HOME/$dep_id/$dir/grails-app/migrations ]; then
                	mkdir -p $HOME/$dep_id/$dir/grails-app/migrations
               		echo "dir create"
             	fi
        	cd $HOME/$dep_id/$dir/ && grails clean
             	cd $HOME/$dep_id/$dir/ && grails war ROOT.war 
		if [ $? = 0 ]; then
                	mkdir -p $HOME/war_$dep_id
                        mv $HOME/$dep_id/$dir/ROOT.war $HOME/war_$dep_id/ROOT.war
			rm -rf $HOME/$dep_id $HOME/file_$dep_id
                        echo '{"code":5000,"success":"true","message":"Grails WAR File Created Successfully","path":"'$HOME/war_$dep_id/ROOT.war'"}'
             	else
                	rm -rf $HOME/$dep_id $HOME/file_$dep_id
                        echo '{"success":"false","code":8301,"message":"Error In Creating Binary"}'
           	fi

        else
                rm -rf $HOME/$dep_id $HOME/file_$dep_id
                echo '{"success":"false","code":8303,"message":"Error In Cloning GIT Repository"}'
        fi;;

delete)

	if [ -d $HOME/war_$dep_id ]; then
		rm -rf $HOME/war_$dep_id
		echo '{"code":5000,"success":"true","message":"WAR File Deleted Successfully"}'
	else
		echo '{"success":"false","code":8304,"message":"Error In Deleting Binary"}'
	fi;;
esac
