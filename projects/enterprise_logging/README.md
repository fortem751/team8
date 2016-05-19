Currently there are two ways we can execute the test harness


1. Run the script which gathers pbench metrics for a chosen test and for a given set of cluster nodes.

	Ex:
	  ./perftest.sh -h

	  # this will execute the E2E's with a scale option of 5, while gathering metrics with pbench.
	  
	  ./perftest.sh -n LoggingSoak_E2E_5 -e 5


2. Run the scripts individually from the utils folder. This will not gather metrics with pbench.

	Ex: 
	  1) ./utils/jdspammer.sh -r 60 -l 512
	  
	  2) EXPORT FD=100 ; EXPORT ES=10 ; ./utils/fluentd_autoscaler.sh 



E2Es:

Relevant Until https://github.com/kubernetes/kubernetes/pull/24536/files merges into upstream kube and openshift...

To run the e2es, you essentially follow these steps.

- git clone jayunit100/kubernetes
- cd kubernetes and checkout branch "LoggingSoak"
- hack/build-go.sh test/e2e/e2e.test

Then, we run the e2e tests, to create noisy logging pods : pods which log 1kb a second, spread out to each individual node on the cluster.

Run the e2e tests with --ginkgo.focus="Logging soak" --scale=[desired number of noisy-logging-pods per node]
so --scale=2 for example, will put 2 pods that log continuously on EVERY node in a cluster (==600 pods on a 300 node cluster, so be careful).
