#!/bin/bash

service=$1

#checking if argument passed or not, if not passed then not running and giving him 
#message back to user.

if [ $# -ne 1 ]
then
	echo "No or multiple argument pass with this shell, please provide a single argument with this."
	echo "Usage: $0 <<name of systemctl service>>"
	echo "Example: $0 sshd"
	exit 1
fi

#echo $service

#checking if service is running or not and if not running, starting it now.

if [ $(systemctl is-active $service) == "active" ]
then
	echo "$service: service is running"
else
	echo "$service: service is not running, starting it now"
	systemctl start $service
fi
