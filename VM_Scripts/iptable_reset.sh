#!/bin/bash

# Flush iptable
/sbin/iptables -t nat -F
# set iptable rules
/bin/sh /opt/iptab/iptables.sh
# save current iptable rule on iptables.rule 
/sbin/iptables-save >/etc/iptables.rule
