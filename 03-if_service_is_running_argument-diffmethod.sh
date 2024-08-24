#!/bin/bash

service=$1

#checking if argument passed or not, if not passed then not running and giving him 
#message back to user.
# $# means, number of argument pass

if [ $# -ne 1 ]
then
	echo "No or multiple argument pass with this shell, please provide a single argument with this."
	echo "Usage: $0 <<name of systemctl service>>"
	echo "Example: $0 sshd"
	exit 1
fi

#echo $service

#checking if service is running or not and if not running, starting it now.

status=`systemctl show --property=ActiveState $service` #you can achieve this same thing from "status=$(systemctl show --property=ActiveState $service)"

if [ "$status" == "ActiveState=active" ]
then
	echo "$service: service is running"
else
	echo "$service: service is not running, starting it now"
	systemctl start $service
fi

#status=`systemctl is-running $service`
#status=$(sudo systemctl show -p SubState $service)
