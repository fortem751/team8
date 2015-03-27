# team8
Here's where we can put the scripts we use for the phx cluster.
Thi


# jenkins

- http://host01-rack10.scale.openstack.engineering.redhat.com:8080/
- symlinked to kube source for all dirs
- the unit files symlinked to source as well

# hacking etcd

Sometimes metadata in etcd caused problems in tha past.  
If curious about how etcd is being used, you can hackishly delete it like this 
- curl -L http://127.0.0.1:4001/v2/keys/registry?recursive=true -XDELETE
