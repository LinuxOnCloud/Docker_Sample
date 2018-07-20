#!/bin/bash

export JAVA_HOME="/opt/jdk1.7.0_21"
export CLASSPATH=.:/opt/jdk1.7.0_21/lib/tools.jar:/opt/java6/jre/lib/rt.jar
export CATALINA_HOME="/opt/apache-tomcat-6.0.37"
export CATALINA_BASE=$CATALINA_HOME
export LOG_PATH=$CATALINA_HOME/logs
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH:$CATALINA_HOME/bin


case $1 in

artifactory)
	artif_ip=`cat /root/.jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml|grep url|cut -d"/" -f3|cut -d ":" -f1`
	echo "Old Artifactory Url = $artif_ip; \nNew Artifactory Url = $2"
	/bin/sed -ie 's/'$artif_ip'/'$2'/g' /root/.jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml	
#	/vmpath/sbin/config_constructor_artifactory $2
	if [ $? -eq 0 ]; then
		/etc/init.d/tomcat stop
		sleep 10
		pid=`/bin/netstat -npl|grep 80|grep java|tail -1|rev|cut -d "/" -f2|awk '{print $1}'|rev`
		echo "Pid = $pid"
		if [ -n "$pid" ]; then
			kill -9 $pid
		fi
		/etc/init.d/tomcat start
		if [ $? -eq 0 ]; then
			echo '{"code":5000,"success":"true","message":"Artifactory Server URL Configured Successfully"}'
		else
			echo '{"success":"false","code":5101,"message":"Artifactory Server URL Could Not Configured"}'
		fi
	else
		echo '{"success":"false","code":5101,"message":"Jenkins Server Restarting Failed"}'
	fi;;


bootstrap)
	
	cd /opt  && git clone https://github.com/chef/chef-repo.git
	if [ $? -eq 0 ]; then
		cd /opt/chef-repo && echo ".chef" >> ~/chef-repo/.gitignore
		mkdir -p /opt/chef-repo/.chef
		if [ $? -eq 0 ]; then
			echo $2 > $HOME/url
	                rgn=`cat $HOME/url|cut -d "/" -f1`
        	        if [ "$rgn" = "cdn.vmpath.com" ]; then
                	        region=us-west-2
                	else
                        	region=us-east-1
                	fi

                	if [ ! -d $HOME/.aws/ ]; then
                        	mkdir -p $HOME/.aws/
                	fi

echo "[default]
output = json
region = $region
aws_access_key_id = AKIAJZOVXPJ5XF656MQQ
aws_secret_access_key = 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" >$HOME/.aws/config

			# download application
	                aws s3 cp s3://$2 /opt/chef-repo/.chef/
			if [ $? -eq 0 ]; then
				user=${2##*/}
				aws s3 cp s3://$3 /opt/chef-repo/.chef/
				if [ $? -eq 0 ]; then
					org=${3##*/}
echo '# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "'$4'"
client_key               "#{current_dir}/'$user'"
validation_client_name   "'$5'-validator"
validation_key           "#{current_dir}/'$org'"
chef_server_url          "https://'$6'/organizations/'$5'"
cookbook_path            ["#{current_dir}/../cookbooks"] ' >  /opt/chef-repo/.chef/knife.rb

					cd /opt/chef-repo && knife ssl fetch
					if [ $? -eq 0 ]; then
						aws s3 cp s3://$7 /opt/chef-repo/.chef/
						if [ $? -eq 0 ]; then
							node_key=${7##*/}
							cd /opt/chef-repo && knife bootstrap $8 -x paasadmin -i /opt/chef-repo/.chef/$node_key --sudo
							if [ $? -eq 0 ]; then
								rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
								echo '{"code":5000,"success":"true", "message":"Chef-Client Bootstrap Process Successfully"}'
							else
								rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
								echo '{"success":"false","code":9501, "message":"Chef-Client Bootstrap Process Failed"}'
							fi
						else
							rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
							echo '{"success":"false","code":9502, "message":"Chef-Client SshKey Download Failed"}'
						fi
					else
						rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
						echo '{"success":"false","code":9503, "message":"Chef-Server SSL Certificate Download Failed"}'
					fi
				else
					rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
					echo '{"success":"false","code":9504, "message":"Chef-Server Organization SshKey Download Failed"}'
				fi
			else
				rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
				echo '{"success":"false","code":9505, "message":"Chef-Server User SshKey Download Failed"}'
			fi
		else
			rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
			echo '{"success":"false","code":9506, "message":".Chef Dir Creation Failed"}'
		fi
	else
		rm -rf  /opt/chef-repo $HOME/url $HOME/.aws/
		echo '{"success":"false","code":9507, "message":"Chef-Repo Cloning Failed"}'
	fi;;


create_job)

                        echo $2 > $HOME/url
                        rgn=`cat $HOME/url|cut -d "/" -f1`
                        if [ "$rgn" = "cdn.vmpath.com" ]; then
                                region=us-west-2
                        else
                                region=us-east-1
                        fi

                        if [ ! -d $HOME/.aws/ ]; then
                                mkdir -p $HOME/.aws/
                        fi

echo "[default]
output = json
region = $region
aws_access_key_id = AKIAJZOVXPJ5XF656MQQ
aws_secret_access_key = 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" >$HOME/.aws/config

echo "#!/bin/bash" > /opt/App42_Config/chef-config.sh
aws s3 cp s3://$2 /opt/App42_Config/
echo "cp /opt/App42_Config/${2##*/} .chef/" >> /opt/App42_Config/chef-config.sh
if [ $? -eq 0 ]; then
aws s3 cp s3://$3 /opt/App42_Config/
echo "cp /opt/App42_Config/${3##*/} .chef/" >> /opt/App42_Config/chef-config.sh
if [ $? -eq 0 ]; then

echo "echo '# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                \"'$4'\"
client_key               \"#{current_dir}/'${2##*/}'\"
validation_client_name   \"'$5'-validator\"
validation_key           \"#{current_dir}/'${3##*/}'\"
chef_server_url          \"https://'$6'/organizations/'$5'\"
cookbook_path            [\"#{current_dir}/../cookbooks\"] ' >  .chef/knife.rb " >>/opt/App42_Config/chef-config.sh
if [ $? -eq 0 ]; then
echo "knife ssl fetch" >>/opt/App42_Config/chef-config.sh
if [ $? -eq 0 ]; then
cp -arf /opt/CookBook_Upload /root/.jenkins/jobs/.
if [ $? -eq 0 ]; then

/etc/init.d/tomcat stop
sleep 10
/etc/init.d/tomcat start
rm -rf  $HOME/.aws/
echo '{"code":5000,"success":"true", "message":"Create CookBook Upload Job Successfully"}'
else
rm -rf  $HOME/.aws/
echo '{"success":"false", "code":8401,"message":"Create CookBook Upload Job Failed"}'
fi
else
rm -rf  $HOME/.aws/
echo '{"success":"false", "code":8401,"message":"Chef-Server SSL Certificate Command Could Not Put On chef-config File"}'
fi
else
rm -rf  $HOME/.aws/
echo '{"success":"false", "code":8401,"message":"Knife.rb Json Could Not Put On chef-config File"}'
fi
else
rm -rf  $HOME/.aws/
echo '{"success":"false", "code":8401,"message":"Chef-Server Org Pem Url Could Not Put On chef-config File"}'
fi
else
rm -rf  $HOME/.aws/
echo '{"success":"false", "code":8401,"message":"Chef-Server User Pem Url Could Not Put On chef-config File"}'
fi;;

esac
