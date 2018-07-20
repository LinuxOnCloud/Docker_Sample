#!/bin/bash

case $1 in

App42_PaaS_VM)
	cd /root/App42_PaaS_VM/ && /usr/bin/git pull 2> error >result
	result=`cat /root/App42_PaaS_VM/result`
	error=`cat /root/App42_PaaS_VM/error`
	if [ -z "$result" ]; then
		/bin/echo "found error = $error"
		/bin/rm -rf /root/App42_PaaS_VM/error
             	/bin/rm -rf /root/App42_PaaS_VM/result
	else
		/bin/echo "result = $result"
		/bin/echo "App42_PaaS_VM updated successfully"
		/bin/rm -rf /root/App42_PaaS_VM/error
                /bin/rm -rf /root/App42_PaaS_VM/result
	fi;;

App42_PaaS_Server)
        cd /root/App42_PaaS_Server/ && /usr/bin/git pull 2> error >result
        result=`cat /root/App42_PaaS_Server/result`
        error=`cat /root/App42_PaaS_Server/error`
        if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_Server/error
                /bin/rm -rf /root/App42_PaaS_Server/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_Server updated successfully"
                /bin/rm -rf /root/App42_PaaS_Server/error
                /bin/rm -rf /root/App42_PaaS_Server/result
        fi;;

App42_PaaS_CM)
	cd /root/App42_PaaS_CM/ && /usr/bin/git pull 2> error >result
	result=`cat /root/App42_PaaS_CM/result`
	error=`cat /root/App42_PaaS_CM/error`
	check=`cat /root/App42_PaaS_CM/result|/usr/bin/awk '{print $1}'`
	if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_CM/error
                /bin/rm -rf /root/App42_PaaS_CM/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_CM updated successfully"
                if [ "$check" = Already ]; then
                        /bin/rm -rf /root/App42_PaaS_CM/error
                        /bin/rm -rf /root/App42_PaaS_CM/result
                else
                        pid=`ps x |/bin/grep java|/bin/grep maven|/bin/grep App42ContainerManager|/usr/bin/awk '{print $1}'`
                        kill -9 $pid
                        /bin/rm -rf /root/App42_PaaS_CM/error
                        /bin/rm -rf /root/App42_PaaS_CM/result
                        cd /root/App42_PaaS_CM/ && /bin/sh run.sh
                        /bin/echo "App42_PaaS_CM updated successfully And App42ContainerManager Service Restarted"
                fi
        fi;;

App42_PaaS_CHM)
        cd /root/App42_PaaS_CHM/ && /usr/bin/git pull 2> error >result
        result=`cat /root/App42_PaaS_CHM/result`
        error=`cat /root/App42_PaaS_CHM/error`
        check=`cat /root/App42_PaaS_CHM/result|/usr/bin/awk '{print $1}'`
        if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_CHM/error
                /bin/rm -rf /root/App42_PaaS_CHM/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_CHM updated successfully"
                if [ "$check" = Already ]; then
                        /bin/rm -rf /root/App42_PaaS_CHM/error
                        /bin/rm -rf /root/App42_PaaS_CHM/result
                else
                        pid=`ps x |/bin/grep java|/bin/grep maven|/bin/grep App42ContainerHealthMonitor|/usr/bin/awk '{print $1}'`
                        kill -9 $pid
                        /bin/rm -rf /root/App42_PaaS_CHM/error
                        /bin/rm -rf /root/App42_PaaS_CHM/result
                        cd /root/App42_PaaS_CHM/ && /bin/sh run.sh
                        /bin/echo "App42_PaaS_CHM updated successfully And App42ContainerHealthMonitor Service Restarted"
                fi
        fi;;

App42_PaaS_Router)
        cd /root/App42_PaaS_Router/ && /usr/bin/git pull 2> error >result
        result=`cat /root/App42_PaaS_Router/result`
        error=`cat /root/App42_PaaS_Router/error`
        check=`cat /root/App42_PaaS_Router/result|/usr/bin/awk '{print $1}'`
        if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_Router/error
                /bin/rm -rf /root/App42_PaaS_Router/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_Router updated successfully"
                if [ "$check" = Already ]; then
                        /bin/rm -rf /root/App42_PaaS_Router/error
                        /bin/rm -rf /root/App42_PaaS_Router/result
                else
                        pid=`ps x |/bin/grep java|/bin/grep maven|/bin/grep App42Router|/usr/bin/awk '{print $1}'`
                        kill -9 $pid
                        /bin/rm -rf /root/App42_PaaS_Router/error
                        /bin/rm -rf /root/App42_PaaS_Router/result
                        cd /root/App42_PaaS_Router/ && /bin/sh run.sh
                        /bin/echo "App42_PaaS_Router updated successfully And App42Router Service Restarted"
                fi
        fi;;

App42_PaaS_Admin_Controller)
        cd /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/ && /usr/bin/git pull 2> error >result
        result=`cat /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/result`
        error=`cat /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/error`
        check=`cat /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/result|/usr/bin/awk '{print $1}'`
        if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/error
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_Admin_Controller updated successfully"
                if [ "$check" = Already ]; then
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/result
                else
                        pid=`ps x |/bin/grep java|/bin/grep maven|/bin/grep App42AdminController|/usr/bin/awk '{print $1}'`
                        kill -9 $pid
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/result
                        cd /root/App42_PaaS_Components/App42_PaaS_Admin_Controller/ && /bin/sh run.sh
                        /bin/echo "App42_PaaS_Admin_Controller updated successfully And App42AdminController Service Restarted"
                fi
        fi;;

App42_PaaS_ResourceManager)
        cd /root/App42_PaaS_Components/App42_PaaS_ResourceManager/ && /usr/bin/git pull 2> error >result
        result=`cat /root/App42_PaaS_Components/App42_PaaS_ResourceManager/result`
        error=`cat /root/App42_PaaS_Components/App42_PaaS_ResourceManager/error`
        check=`cat /root/App42_PaaS_Components/App42_PaaS_ResourceManager/result|/usr/bin/awk '{print $1}'`
        if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_ResourceManager/error
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_ResourceManager/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_ResourceManager updated successfully"
                if [ "$check" = Already ]; then
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_ResourceManager/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_ResourceManager/result
                else
                        pid=`ps x |/bin/grep java|/bin/grep maven|/bin/grep App42ResourceManager|/usr/bin/awk '{print $1}'`
                        kill -9 $pid
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_ResourceManager/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_ResourceManager/result
                        cd /root/App42_PaaS_Components/App42_PaaS_ResourceManager/ && /bin/sh run.sh
                        /bin/echo "App42_PaaS_ResourceManager updated successfully And App42ResourceManager Service Restarted"
                fi
        fi;;

App42_PaaS_VHM)
        cd /root/App42_PaaS_Components/App42_PaaS_VHM/ && /usr/bin/git pull 2> error >result
        result=`cat /root/App42_PaaS_Components/App42_PaaS_VHM/result`
        error=`cat /root/App42_PaaS_Components/App42_PaaS_VHM/error`
        check=`cat /root/App42_PaaS_Components/App42_PaaS_VHM/result|/usr/bin/awk '{print $1}'`
        if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VHM/error
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VHM/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_VHM updated successfully"
                if [ "$check" = Already ]; then
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VHM/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VHM/result
                else
                        pid=`ps x |/bin/grep java|/bin/grep maven|/bin/grep App42VMHealthMonitor|/usr/bin/awk '{print $1}'`
                        kill -9 $pid
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VHM/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VHM/result
                        cd /root/App42_PaaS_Components/App42_PaaS_VHM/ && /bin/sh run.sh
                        /bin/echo "App42_PaaS_VHM updated successfully And App42VMHealthMonitor Service Restarted"
                fi
        fi;;

App42_PaaS_VM_Manager)
        cd /root/App42_PaaS_Components/App42_PaaS_VM_Manager/ && /usr/bin/git pull 2> error >result
        result=`cat /root/App42_PaaS_Components/App42_PaaS_VM_Manager/result`
        error=`cat /root/App42_PaaS_Components/App42_PaaS_VM_Manager/error`
        check=`cat /root/App42_PaaS_Components/App42_PaaS_VM_Manager/result|/usr/bin/awk '{print $1}'`
        if [ -z "$result" ]; then
                /bin/echo "found error = $error"
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VM_Manager/error
                /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VM_Manager/result
        else
                /bin/echo "result = $result"
                /bin/echo "App42_PaaS_VM_Manager updated successfully"
                if [ "$check" = Already ]; then
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VM_Manager/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VM_Manager/result
                else
                        pid=`ps x |/bin/grep java|/bin/grep maven|/bin/grep App42VMManager|/usr/bin/awk '{print $1}'`
                        kill -9 $pid
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VM_Manager/error
                        /bin/rm -rf /root/App42_PaaS_Components/App42_PaaS_VM_Manager/result
                        cd /root/App42_PaaS_Components/App42_PaaS_VM_Manager/ && /bin/sh run.sh
                        /bin/echo "App42_PaaS_VM_Manager updated successfully And App42VMManager Service Restarted"
                fi
        fi;;

*)
                echo 'Invalid Command'
                echo 'Usage: {App42_PaaS_VM|App42_PaaS_CM|App42_PaaS_CHM|App42_PaaS_Router|App42_PaaS_Admin_Controller|App42_PaaS_ResourceManager|App42_PaaS_VHM|App42_PaaS_VM_Manager|App42_PaaS_Server}'
                ;;
esac
