#/bin/bash!

while true; 
do
    x=`date +%s`
    y=`kubectl get pods | grep unning | wc -l`
    z=`kubectl get pods | grep ending | wc -l` 
    echo "$x $y $z"
    sleep 2 
done
