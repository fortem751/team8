# set -x

function clean() {
    echo "deleting all fluentd and elastic search"
	oc scale dc/logging-fluentd --replicas=0

	# Kill off all the ES servers.
	oc delete rc `oc get rc | grep logging-es | cut -d' ' -f 1`

    # now, manually delete all pods.  fluentd shoudlnt be many, but es may have orphans...?
	for f in `oc get pods | grep logging-es | cut -d' ' -f 1 ` ; do oc delete pod $f ; done
	for f in `oc get pods | grep fluentd | cut -d' ' -f 1 ` ; do oc delete pod $f ; done
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

# Scale fluentd, and wait 1 minute to see if logs start increasing.
function scale_fluentd_and_measure_log_count() {
	for i in `seq 1 1 10` ; do 
		oc scale dc/logging-fluentd --replicas=$FD
		sleep 6
		amt_es=`oc get pods | grep logging-es | grep Running | wc -l`
		amt_flu=`oc get pods | grep fluent | grep Running | wc -l`
		cnt=`report`
		cnt=$(( $cnt + 1)) # add 1 incase of zero val
		echo "$i: elastic_goal:$ES,fluent_goal:$FD,fluent_actual:$amt_flu,elastic_actual:$amt_es,kibana_size:$cnt"
	done
}

clean
es
if [ -z "$FD" ]; then
    echo "Need to set FD: Number of fluentds!"
    exit 1
fi  

if [ -z "$ES" ]; then
    echo "Need to set ES:Number of es nodes!"
    exit 1
fi
scale_fluentd_and_measure_log_count
