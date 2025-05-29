#!/usr/bin/env bash

#set -x

#This one is perfectly working.
#while read name; do ping -c1 "$name" 2> /dev/null; done <$1

#Need to check with "bash -c" cause it is not working.
#while read name; do bash -c 'ping -c1 "$name" ; exec /bin/bash' 2>/dev/null; done <$1

#This one is  also working.
#while read -r ip; do ping -c1 "$ip" 2>/dev/null; done <$1

#Checking last
while IFS= read -r line; do ping -c1 "$line"; done <$1
