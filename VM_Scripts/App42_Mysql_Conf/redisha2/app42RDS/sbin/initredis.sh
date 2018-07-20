#!/bin/bash
echo "#!/bin/sh
#
# redis        init file for starting up the redis daemon
#
# chkconfig:   - 20 80
# description: Starts and stops the redis daemon.
#
### BEGIN INIT INFO
# Provides: redis-server
# Required-Start: \$local_fs \$remote_fs \$network
# Required-Stop: \$local_fs \$remote_fs \$network
# Short-Description: start and stop Redis server
# Description: A persistent key-value database
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

name=\"redis-server\"
exec=\"/usr/bin/\$name\"
shut=\"/usr/bin/redis-cli\"
arg=\"-a\"
passwd=\"\$2\"
pidfile=\"/var/run/redis/redis.pid\"
REDIS_CONFIG=\"/etc/redis.conf\"

[ -e /etc/sysconfig/redis ] && . /etc/sysconfig/redis

lockfile=/var/lock/subsys/redis

start() {
    [ -f \$REDIS_CONFIG ] || exit 6
    [ -x \$exec ] || exit 5
    echo -n $\"Starting \$name: \"
    \$exec \$REDIS_CONFIG --daemonize yes --pidfile \$pidfile
    retval=\$?
    echo
    [ \$retval -eq 0 ] && touch \$lockfile
    return \$retval
}

stop() {
    echo -n $\"Stopping \$name: \"
    [ -x \$shut ] && echo \"shutdown\"|\$shut \$arg \$passwd
    retval=\$?
    if [ -f \$pidfile ]
    then
        # shutdown haven't work, try old way
        killproc -p \$pidfile \$name
        retval=\$?
    else
        success \"\$name shutdown\"
    fi
    echo
    [ \$retval -eq 0 ] && rm -f \$lockfile
    return \$retval
}

restart() {
    stop
    start
}

rh_status() {
    status -p \$pidfile \$name
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}


case \"\$1\" in
    start)
        # 0
        \$1
        ;;
    stop)
        # 0
        \$1
        ;;
    restart)
        \$1
        ;;
    reload)
        # 7
        \$1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        # 0
        restart
        ;;
    *)
        echo $\"Usage: \$0 {start|stop|status|restart|condrestart|try-restart}\"
        exit 2
esac
exit \$?" > /etc/init.d/redis

chmod 755 /etc/init.d/redis
