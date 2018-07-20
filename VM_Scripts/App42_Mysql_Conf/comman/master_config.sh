#!/bin/bash

if [ "$1" == "poiuytrewq" ]; then

total_mem=`free -m|head -2|tail -1|awk '{print $2}'`
idb_pool=`echo "$total_mem * 70 / 100"|bc`
query_cache=`echo "$total_mem * 30 / 100"|bc`
read_buffer=`echo "$total_mem * 10 / 100"|bc`

echo "[mysqld]
datadir=/var/lib/mysql/mysql
socket=/var/lib/mysql/mysql/mysql.sock
symbolic-links=0
innodb_file_per_table = 1
#innodb_thread_concurrency = 128
innodb_thread_concurrency = 0
#query_cache_size = $query_cache"M"
query_cache_size = 0
#thread_cache_size = 8
thread_cache_size = 0
#myisam_sort_buffer_size = 8M
myisam_sort_buffer_size = 8388608
#read_rnd_buffer_size = $query_cache"M"
read_rnd_buffer_size = 524288
#read_buffer_size = $read_buffer"M"
read_buffer_size = 262144
#sort_buffer_size = $query_cache"M"
sort_buffer_size = 2097152
#table_open_cache = 128
table_open_cache = 400
#max_allowed_packet = 1G
max_allowed_packet = 1048576
slave_max_allowed_packet = 1073741824
#key_buffer_size = 128M
key_buffer_size = 16777216
wait_timeout = 31536000
innodb_buffer_pool_size = $idb_pool"M"
innodb_flush_method=O_DIRECT
innodb_io_capacity = 5000
innodb_doublewrite = 0
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 256M
innodb_log_file_size = 512MB
innodb_log_files_in_group = 2

log_bin = /var/lib/mysql/mysql-binlog/mysqld-bin.log
expire_logs_days = 10
max_binlog_size = 200M
max_connections = $2
max_connect_errors = 1000000000
binlog_format = MIXED

relay-log = /var/lib/mysql/mysql-binlog/mysql-relay-bin.log
relay_log_space_limit=2G
relay-log-purge=1
max_relay_log_size = 100M

server-id=1

open_files_limit=65535
symbolic-links=0
sql_mode=\"\"
#validate-password=off

lower_case_table_names=1

slow_query_log = 1
slow_query_log_file = /var/lib/mysql/logs/mysql-slow.log
long_query_time = 0.150

log-error=/var/lib/mysql/logs/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

[mysqladmin]
socket=/var/lib/mysql/mysql/mysql.sock


[client]
port=3306
socket=/var/lib/mysql/mysql/mysql.sock

[mysqld_safe]
log-error=/var/lib/mysql/logs/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid" > /home/azureuser/Installationpkg/comman/master.cnf

else
        echo "You are not authourize person, Please leave now."
        exit
fi
