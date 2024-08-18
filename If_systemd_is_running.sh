#!/bin/bash

# List the inactive services

InactService=`systemctl --state=inactive | awk '{print$1}' | grep "service$"`

# Creating a "for" loop statement so that we can iterate every element from the InactService array.
# We are also applying a conditional statement, so that we can check if service is inactive and if it is inactive, we are starting it up.

for element in ${InactService}
do
  echo $element
  if [ $(systemctl is-active $element) == "inactive" ];
  then
    echo "System is inactive: $element"
    #systemctl start $element
    echo "$element : service is started"
    #if [ $(systemctl is-active | grep $element) == $element ]
  else
    echo $element
    continue
  fi
done
