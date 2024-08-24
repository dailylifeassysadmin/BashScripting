#!/bin/bash

service=$1

# -x or +x set for logging in bash
#set -x
#set +x

# color variables
bg_red='\033[0;41m'
bg_green='\033[0;42m'
bg_yellow='\033[0;43m'
bg_blue='\033[0;44m'
bg_magenta='\033[0;45m'
bg_cyan='\033[0;46m'

# clear the color after that:
clear='\033[0m'

#checking if argument passed or not, if not passed then not running and giving him 
#message back to user.
# $# means, number of argument pass

if [ $# -ne 1 ]
then
	echo -e "${bg_red}** No or multiple argument pass with this shell, please provide a single argument with this.${clear}"
	echo -e "${bg_yellow}Usage: $0 <<name of systemctl service>>${clear}"
	echo -e "${bg_green}Example: $0 sshd${clear}"
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