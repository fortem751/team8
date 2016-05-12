#!/usr/bin/env bash

ERR=1
OK=0

function setup_globals() {
	: '
	Parameters:
	$1 KUBEREPO - kubernetes repo location
	$2 PBENCH_RES - pbench results directory
	'

	# e2es
	export KUBEREPO=${1:-'/opt/jay/kubernetes'}
	export TESTBIN=$KUBEREPO/_output/local/bin/linux/amd64/e2e.test

	# pbench
	export PB_RES=${2:-'/var/lib/pbench-agent'}
	export TEST_NAME=$1
}

function check_required() {
	if [ ! -f $TESTBIN ]; then
		echo "Please build e2e test first. Exit."
		exit 1
	fi

	if [[ -z $TESTNAME ]]; then
		echo "Run example:"
		echo "$(basename $0) loge2e_test1_e2e100"
		exit 1
	fi	
}

function usage() {
	echo '
	Accepted parameters::
	[*] are required

	-n <test name> [*]
	-e <e2e test>
	-s <scale> 
	-j <journalctl spammer>

	Example: 
	./perftest.sh -n logging_e2e100_01012016 -e 100'
}

function parse_opts() {
	: '
	Accepted parameters::
	[*] are required

	-n <test name> [*]
	-e <e2e test>
	-s <scale> 
	-j <journalctl spammer>
	'

	while getopts ":n:e:s:j:h:" option; do
	    case "${option}" in
		n)
		    TESTNAME=${OPTARG}
		    ;;
		e)
		    E2E=${OPTARG}
		    ;;
		s)
		    SCALE=${OPTARG}
			;;
		j)
		    JOURNALD=${OPTARG}
			;;
		h)
		    usage
		    ;;

		*)
		    echo "Invalid option: ${option} Exiting."
		    exit $ERR
		    ;;

	    esac
	done
	shift $((OPTIND-1))
}

function clean_pbench() {
	echo "[*] Stopping tools..."
	pbench-stop-tools &> /dev/null
	pbench-kill-tools &> /dev/null
	pbench-clear-tools  &> /dev/null
	echo "[*] Done"

}

function perftest() {
	# TODO: Switchcase to either run
	# 1. e2e loggin soak ; --scale=$x
	# 2. scale test
	
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
