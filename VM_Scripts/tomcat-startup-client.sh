case "$1" in
        # start tomcat function
        start)
                sudo /etc/init.d/tomcat starts ;;

        # stop tomcat function
        stop)
                sudo /etc/init.d/tomcat stop ;;
esac

