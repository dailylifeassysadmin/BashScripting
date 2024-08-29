#!/bin/bash

# testing ping to list of servers
# saving server 's details in a list
ServerList="www.google.com www.yahoo.in www.office.com www.ubuntu.com www.outlook.com www.github.com"

# saving server 's details in a array
ServerArray=("www.google.com" "www.yahoo.in" "www.office.com" "www.ubuntu.com" "www.outlook.com" "www.github.com")

#set -- $ServerList
#echo $2, $1, $3, $4, $6, $7
#echo ${ServerArray[0]}
#echo ${ServerArray[@]}
echo ${!ServerArray[@]}
echo ${#ServerArray[@]}

# now we are iterating one by one via a "for" loop with list method.
#for i in $ServerList; do
#    echo -e "$i\n"
#done
set -x

# now we are iterating one by one via a "for" loop with array method.
for i in ${ServerArray[@]}; do
    ping -c 2 $i > /dev/null 2>&1
    #echo -e "\n"
    if [ $? -eq 0 ]; then
        echo "$i: Connected" >> $0.txt
        for j in ${!ServerArray[@]}; do
            if [[ $(expr $j+1) -eq ${#ServerArray[@]} ]]; then
                echo "-------------------------" >> $0.txt
            fi
        done
    else
        echo "$i: Not Connected" >> $0.error.txt
        if [{ ${#ServerArray[@]} == ${#ServerArray[@]} }]; then
            echo "-------------------------" >> $0.error.txt
        fi
    fi
done
#if [ -f $0.txt ]; then
#    echo "-------------------------" >> $0.txt
#else
#    echo "-------------------------" >> $0.error.txt
#fi