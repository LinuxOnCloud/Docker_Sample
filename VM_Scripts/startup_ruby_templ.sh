#!/bin/bash
old_container=$1
new_container=$2

if [ $old_container = ruby20_passenger40 ] || [ $old_container = rails40_passenger40 ] || [ $old_container = sinatra14_passenger40 ] || [ $old_container = ruby20_thin16 ] || [ $old_container = ruby20_unicorn47 ] || [ $old_container = nodejs01022 ] || [ $old_container = python27 ] || [ $old_container = go13_nginx16 ]; then
        /vmpath/sbin/app42_agent_commander $new_container start >/dev/null
fi
