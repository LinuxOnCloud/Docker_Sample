 #!/bin/sh
  #
  # Startup script for the Jakarta Tomcat Java Servlets and JSP server
  #
  # chkconfig: - 85 15
  # description: Jakarta Tomcat Java Servlets and JSP server
  # processname: tomcat
  # pidfile: /var/run/tomcat.pid
  # config:

  # Source function library.
  # . /etc/rc.d/init.d/functions

  # Source networking configuration.
  #. /etc/sysconfig/network

  # Check that networking is up.
  #[ ${NETWORKING} = "no" ] && exit 0

  # Set Tomcat environment.

  user=`getent passwd 1002 |cut -d':' -f1`

  export JAVA_HOME="/opt/java7"
  export CLASSPATH=.:/opt/java7/lib/tools.jar:/opt/java7/jre/lib/rt.jar
  export CATALINA_HOME="/opt/tomcat"
  export CATALINA_BASE=$CATALINA_HOME
  export LOG_PATH=$CATALINA_HOME/logs
  export CATALINA_OPTS="-server -Xms64m -Xmx512m -Dbuild.compiler.emacs=true"
  export PATH=/opt/java7/bin:/opt/java7/jre/bin:$PATH


  [ -f /opt/tomcat/bin/startup.sh ] || exit 0
  [ -f /opt/tomcat/bin/shutdown.sh ] || exit 0

  export PATH=$PATH:/usr/bin:/usr/local/bin

  # See how we were called.
  case "$1" in
    start)
          # Start daemon.
	  /bin/sh /root/log_rename.sh
          echo -n "Starting Tomcat: "
 	  /bin/su -p -s /bin/sh $user $CATALINA_HOME/bin/startup.sh start
 	  #/bin/sh $CATALINA_HOME/bin/startup.sh start
          ;;
    starts)
          # Start daemon.
          echo -n "Starting Tomcat: "
 	  /bin/su -p -s /bin/sh $user $CATALINA_HOME/bin/startup.sh start
          #/bin/sh $CATALINA_HOME/bin/startup.sh start
          ;;
    stop)
          # Stop daemons.
          echo -n "Shutting down Tomcat: "
 	  /bin/su -p -s /bin/sh $user $CATALINA_HOME/bin/shutdown.sh stop
    #      /bin/sh $CATALINA_HOME/bin/shutdown.sh stop
          ;;
    restart)
          $0 stop
          $0 starts
          ;;
    status)
          status tomcat
          ;;
    *)
          echo "Usage: $0 {start|stop|restart|status}"
          exit 1
  esac

  exit 0
