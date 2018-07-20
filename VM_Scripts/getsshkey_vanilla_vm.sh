#!/bin/bash

wget --no-check-certificate --directory-prefix=$HOME/download $1

if [ $? -eq 0 ]; then
        fileWithExt=${1##*/}
        cat $HOME/download/$fileWithExt > /home/paasadmin/.ssh/authorized_keys
        echo '{"code":5000,"success":"true", "message":"SSH Key Added Successfully"}'
else
        echo '{"success":"false", "code":9202,"message":"SSH Key Download Failed"}'
fi

