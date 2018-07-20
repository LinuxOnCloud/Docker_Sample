#!/bin/bash

export JAVA_HOME="/opt/java/"
export PATH=$PATH:$JAVA_HOME/bin
DAEMON=/usr/bin/ant
SCRIPT_NAME=/home/paasadmin/appwarp-conf/appwarp
APP_PATH=/home/paasadmin/app/appwarp
Startup_File=warp.xml

appwarpstart() {

cd $APP_PATH && $DAEMON -f $Startup_File &

}

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

case "$1" in
  start)
        appwarpstart
        ;;
  stop)
        sudo pkill -9 java &
        ;;
  *)
        echo "Usage: $SCRIPT_NAME {start|stop|restart}" >&2
        exit 3
        ;;
esac
