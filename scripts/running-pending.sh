#!/bin/bash
while true; 
do
   ddd=`date +%H:%M:%S,%s` ;
   raw=`kubectl -s http://kube-apiserver.scale.openstack.engineering.redhat.com:8080 get pods` ;
   pending=$(echo "$raw" | grep ending | wc -l) 
   running=$(echo "$raw" | grep unning | wc -l) 
   waiting=$(echo "$raw" | grep aiting | wc -l) 
   echo "$ddd,$running,$pending,$waiting" ;
   sleep 1;
done
