#/bin/bash!

while true; do date +%s; kubectl get pods | grep unning | wc -l ; kubectl get pods | grep ending | wc -l ; sleep 2 ; echo "---"
