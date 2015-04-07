kubectl get pods

### just glom commands together
### there is a very rare chance any will fail
### so sophisticated reporting isnt really necessary
echo "TESTING ETCD" && \
(cd /mnt/build/team8/scripts/ && ./etcdsmoke.sh) && \
echo "TESTING KUBECTL on the network" && \
kubectl --server=http://host18-rack11:8080 get pods && \
exit 0  


echo "TEST FAILED ! Something is severely broken on this kubernetes cluster."
exit 1
