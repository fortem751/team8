# set -x

function clean() {
	oc scale dc/logging-fluentd --replicas=0
	for f in `oc get pods | grep logging-es | cut -d' ' -f 1 ` ; do oc delete pod $f ; done
}

POD=`oc get pods | grep kibana | cut -d' ' -f 1`

function es() { 
	for i in `seq 1 1 $ES`; do
		oc process logging-es-template | oc create -f -
	done
	echo "Done creating $ES Nodes, sleeping..."
	sleep 30
}

function report() {
	oc exec $POD -- curl --connect-timeout 2 -s -k --cert /etc/kibana/keys/cert --key /etc/kibana/keys/key https://logging-es:9200/.operations*/_count | python -mjson.tool | grep count | cut -d':' -f 2-10 
}

# This function scales fluentd log generators 
# Af each scale, it waits a minute, and then checks how many total logs are in kibana.
function run() {
	for i in `seq 1 20 300` ; do 
		oc scale dc/logging-fluentd --replicas=$i
		sleep 60
		amt=`oc get pods | grep fluent | grep Running | wc -l`
		cnt=`report`
		cnt=$(( $cnt + 1)) # add 1 incase of zero val
		echo "$amt $cnt pods/es_count = $(( $amt / $cnt ))"
	done
}

clean

echo "need to figure out how to spread !!!!!!" 
es 
run
