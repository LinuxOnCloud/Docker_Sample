#!/bin/bash
old_container=$1
new_container=$2

if [ $old_container = ruby25_passenger53 ] || [ $old_container = rails52_passenger53 ] || [ $old_container = sinatra20_passenger53 ] || [ $old_container = ruby25_thin17 ] || [ $old_container = ruby25_unicorn54 ] || [ $old_container = nodejs1030 ] || [ $old_container = python35_django20 ] || [ $old_container = go13_nginx16 ]; then
        /vmpath/sbin/app42_agent_commander $new_container start >/dev/null
fi
