#!/bin/bash


if [ "$1" == "qwertyuiop" ]; then

cluster=`hostname |cut -d"-" -f1`
node=`hostname`

echo "# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please consult the documentation for further information on configuration options:
# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
#
# ---------------------------------- Cluster -----------------------------------
#
# Use a descriptive name for your cluster:
#
cluster.name: $cluster
#
# ------------------------------------ Node ------------------------------------
#
# Use a descriptive name for the node:
#
node.name: $node
node.master: true
node.data: true
node.ingest: false
script.engine.groovy.inline.aggs: on
#
# Add custom attributes to the node:
#
#node.attr.rack: r1

thread_pool:
    index:
        size: 2
        queue_size: $2
    get:
        size: 30
        queue_size: $2
    bulk:
        size: 2
        queue_size: $2
#
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /var/lib/elasticsearch/data/
#
# Path to log files:
#
path.logs: /var/lib/elasticsearch/logs/
#
# ----------------------------------- Memory -----------------------------------
#
# Lock the memory on startup:
#
#bootstrap.memory_lock: true
bootstrap.seccomp: false
#
# Make sure that the heap size is set to about half the memory available
# on the system and that the owner of the process is allowed to use this
# limit.
#
# Elasticsearch performs poorly when the system is swapping the memory.
#
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: 0.0.0.0
#
# Set a custom port for HTTP:
#
#http.port: 9200
#
# For more information, consult the network module documentation.
#
# --------------------------------- Discovery ----------------------------------
#
# Pass an initial list of hosts to perform discovery when new node is started:
# The default list of hosts is ["'"127.0.0.1", "[::1]"]
#
discovery.zen.ping.unicast.hosts: ["10.20.1.5", "10.20.1.6", "10.20.1.7", "10.20.1.8"]
#
# Prevent the "split brain"'" by configuring the majority of nodes (total number of master-eligible nodes / 2 + 1):
#
discovery.zen.minimum_master_nodes: 1
#
# For more information, consult the zen discovery module documentation.
#
# ---------------------------------- Gateway -----------------------------------
#
# Block initial recovery after a full cluster restart until N nodes are started:
#
#gateway.recover_after_nodes: 3
#
# For more information, consult the gateway module documentation.
#
# ---------------------------------- Various -----------------------------------
#
# Require explicit names when deleting indices:
#
#action.destructive_requires_name: true" > /app42RDS/sbin/elasticsearch.yml

else
        echo "You are not authourize person, Please leave now."
        exit
fi

