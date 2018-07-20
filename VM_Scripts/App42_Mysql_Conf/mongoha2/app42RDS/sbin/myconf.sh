#!/bin/bash

replica_name=`hostname |cut -d "-" -f1`

if [ "$1" == "qwertyuiop" ]; then

echo "# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/lib/mongo/logs/mongod.log

# Where and how to store data.
storage:
  dbPath: /var/lib/mongo/data
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid  # location of pidfile

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0  # Listen to local interface only, comment to listen on all interfaces.
  maxIncomingConnections: $2

  http:
    enabled: true
    JSONPEnabled: true
    RESTInterfaceEnabled: true


#security:
  #keyFile: /var/lib/mongo/mongodb-keyfile
  #authorization: enabled

#operationProfiling:

replication:
   oplogSizeMB: 2048
   replSetName: $replica_name
setParameter:
   enableLocalhostAuthBypass: false
#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:" > /home/azureuser/Installationpkg/mongoha2/app42RDS/sbin/mongod.conf

else
        echo "You are not authourize person, Please leave now."
        exit
fi

