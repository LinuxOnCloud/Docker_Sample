#!/bin/bash

#wget --no-check-certificate --directory-prefix=$HOME/download $1

                echo $1 > $HOME/url
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
aws_access_key_id = xxxxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxx" >$HOME/.aws/config
		
		if [ ! -d $HOME/download ]; then
                        mkdir -p $HOME/download
                fi
                # download application
                aws s3 cp s3://$1 $HOME/download/

if [ $? -eq 0 ]; then
        fileWithExt=${1##*/}
        cat $HOME/download/$fileWithExt > /home/paasadmin/.ssh/authorized_keys
	rm -rf $HOME/download/ $HOME/.aws/ $HOME/url
        echo '{"code":5000,"success":"true", "message":"SSH Key Added Successfully"}'
else
        echo '{"success":"false", "code":9202,"message":"SSH Key Download Failed"}'
	rm -rf $HOME/download/ $HOME/.aws/ $HOME/url
fi

