Relevant Until https://github.com/kubernetes/kubernetes/pull/24536/files merges into upstream kube and openshift...

To run the e2es, you essentially follow these steps.

- git clone jayunit100/kubernetes
- cd kubernetes and checkout branch "LoggingSoak"
- hack/build-go.sh test/e2e/e2e.test

Then, we run the e2e tests, to create noisy logging pods : pods which log 1kb a second, spread out to each individual node on the cluster.

Run the e2e tests with --ginkgo.focus="Logging soak" --scale=[desired number of noisy-logging-pods per node]

so --scale=2 for example, will put 2 pods that log continuously on EVERY node in a cluster (==600 pods on a 300 node cluster, so be careful).
