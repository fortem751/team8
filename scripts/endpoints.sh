#!/bin/bash
while true; 
do
   ddd=`date +%H:%M:%S,%s` ;
   raw=`kubectl get endpoints` ;
   echo "$ddd\n$raw" ;
   sleep 1;
done
