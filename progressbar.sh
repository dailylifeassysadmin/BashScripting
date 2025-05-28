#!/usr/bin/env bash
#
#value=("-" "\" "|" "/")
#
#echo ${value[@]}
#
#for i in ${value[*]}
#do
#echo $1
#done
#



#!/bin/sh

#set -x

BAR='####################'   # this is full bar, e.g. 20 chars

for i in {1..20}; do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep .1                 # wait 100ms between "frames"
#    echo -ne "\n"
done
echo -ne "\n"
#echo -ne "\r"
#
#values='#1#2#3#4#5#6#7#8#9'
#
#echo -e "${values:5:5}\n"
#
#bar='| / - \'
#echo $bar
#for i in $bar;do
#    echo -ne "\r$i"
#    sleep 2
#done
#echo -ne "\n"

#bar=(| / - \)
#set -x
#i=0
#while true;do
#    echo -ne "\r${bar[$i]}"
#    ((i++))
#    sleep 1
#done
#echo -ne "\n"
