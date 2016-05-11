#!/usr/bin/env bash

# e2es
KUBE="/opt/jay/kubernetes"
TESTBIN=$KUBE/_output/local/bin/linux/amd64/e2e.test

# pbench
PB_RES='/var/lib/pbench-agent'
TEST_NAME=$1


function checkrequired() {
	if [ ! -f $TESTBIN ]; then
		echo "Please build e2e test first. Exit."
		exit 1
	fi

	if [[ -z $1 ]]; then
		echo "Run example:"
		echo "$(basename $0) loge2e_test1"
		exit 1
	fi	
}

function clean() {
	echo "[*] Stopping tools..."
	pbench-stop-tools &> /dev/null
	pbench-kill-tools &> /dev/null
	pbench-clear-tools  &> /dev/null
}

function perftest() {
	# TODO: Switchcase to either run
	# 1. e2e ; --scale=$x
	# 2. scale test
	# 3. journalctl spammer
	
	pbench-register-tool-set --interval=10

	# register pbench on every node
	NODES=("$@")
	for NODE in ${NODES[@]}
	  do
		echo "[*] Working on $NODE"
		pbench-register-tool-set --remote=$NODE --interval=10
		#pbench-register-tool --name=pprof --remote=$NODE -- --osecomponent=master
	done

	echo "[*] Available tools"
	pbench-list-tools

	echo "[*] Starting test"
	pbench-start-tools -d $PB_RES/$TEST_NAME

	$TESTBIN --repo-root=./ --ginkgo.focus="Logging" --kubeconfig=/home/cloud-user/.kube/config --scale=100

	pbench-stop-tools -d $PB_RES/$TEST_NAME &> /dev/null
	pbench-postprocess-tools -d $PB_RES/$TEST_NAME
	pbench-copy-results
}


NODELIST=("192.1.11.83 192.1.11.226 192.1.11.66")

checkrequired $@
clean
perftest ${NODELIST[@]}
[[ $? -eq 0 ]] && exit 0 || exit 1
