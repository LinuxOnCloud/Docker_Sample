#!/bin/bash

d=`/usr/bin/chage -l root|grep "Password expires"|cut -d ":" -f2|awk '{print $4}'`

if [ "$d" = "changed" ]; then
	/usr/sbin/usermod -p "" root
fi

