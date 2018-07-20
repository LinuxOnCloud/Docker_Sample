EMAIL="abc@example.com"
mail -s "newTest App42RDS Mysql Failover = New Master - 10.20.1.7" $Email < /var/log/masterha/master-mysql/master-mysql.log
