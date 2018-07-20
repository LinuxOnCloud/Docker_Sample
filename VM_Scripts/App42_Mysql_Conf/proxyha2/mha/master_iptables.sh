iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 3306 --to-destination 10.20.1.8:3306
ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -F
ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ssh -i /root/.ssh/id_rsa root@10.20.1.5 iptables -t nat -I PREROUTING -s 0.0.0.0/0 -p tcp -j DNAT --dport 3306 --to-destination 10.20.1.8:3306
