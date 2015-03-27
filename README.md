# team8
Here's where we can put the scripts we use for the phx cluster.
Thi


# jenkins

- http://host01-rack10.scale.openstack.engineering.redhat.com:8080/ writes build to /mnt/build .
- symlinked to kube source for all dirs ( /mnt/build/ )
- the unit files symlinked to source as well

# hacking etcd

Sometimes metadata in etcd caused problems in tha past.  
If curious about how etcd is being used, you can hackishly delete its entries like this 
Obviously this can cause lots of problems, so be careful !
- curl -L http://127.0.0.1:4001/v2/keys/registry?recursive=true -XDELETE


# running go tests

To run the ginko tests, you can do this from the src dir.
```go run ./cmd/e2e/e2e.go --provider="local" --host="http://127.0.0.1:8080" -t "kubectl" --auth_config=/tmp/kubernetes_auth``` 

This allows you to do tests like rolling updates (filter "kubectl") , pod density (filter "Density"), and so on.  k8petstore and others will be added there to.
