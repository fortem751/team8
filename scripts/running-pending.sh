#!/bin/bash
while true; 
do
   ddd=`date +%H:%M:%S,%s` ;
   raw=`kubectl get pods` ;
   pending=$(echo "$raw" | grep ending | grep host | wc -l) 
   running=$(echo "$raw" | grep unning | grep host | wc -l) 
   echo "$ddd,$running,$pending" ;
   sleep 1;
done
