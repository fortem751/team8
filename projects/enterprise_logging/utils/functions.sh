#!/usr/bin/env bash
#set -x
ERR=1
OK=0

function setup_globals() {
	: '
	Parameters:
	$1 KUBEREPO - kubernetes repo location
	$2 PBENCH_RES - pbench results directory
	'

	# e2es
	export KUBEREPO=${1:-'/opt/kubernetes'}
	export TESTBIN=$KUBEREPO/_output/local/bin/linux/amd64/e2e.test

	# pbench
	export PB_RES=${2:-'/var/lib/pbench-agent'}
}

function check_required() {
	if [ ! -f $TESTBIN ]; then
		echo "Please build e2e test first:"
		echo "[1] git clone https://github.com/jayunit100/kubernetes"
		echo "[2] cd $KUBEREPO && sudo hack/build-go.sh test/e2e/e2e.test"
		exit $ERR
	fi

	if [[ -z $TESTNAME ]]; then
		usage
		exit $ERR
	fi	
}



function parse_opts() {
	: '
	Accepted parameters::
	[*] are required

	-n <test name> 	logSoak1 [*]
	-e <e2e test>  	1 
	-s <scale> 	1
	-j <jctl>	1
	'

	while getopts ":n:e:s:j:h:" option; do
	    case "${option}" in
		n)
		    TESTNAME=${OPTARG}
		    ;;
		e)
		    E2E=${OPTARG}
		    RUN_TYPE="e2e"
		    CMD="$TESTBIN --repo-root=./ --ginkgo.focus=\"Logging\" --kubeconfig=/home/cloud-user/.kube/config --scale=$E2E"

		    ;;
		s)
		    SCALE=${OPTARG}
		    RUN_TYPE="scale"
		    CMD="/scale/cmd/with/opts $SCALE"
		    ;;
		j)
		    JOURNALD=${OPTARG}
		    RUN_type="jctl"
		    CMD="/jctl/cmd/with/opts $JOURNALD"
		    ;;
		h)
		    usage
		    ;;

		*)
		    echo -e "Invalid option / usage: ${option}\nExiting."
		    exit $ERR
		    ;;

	    esac
	done
	shift $((OPTIND-1))
}

function clean_pbench() {
	echo "[*] Stopping pbench tools..."
	pbench-stop-tools &> /dev/null
	pbench-kill-tools &> /dev/null
	pbench-clear-tools  &> /dev/null
	echo "[*] Done"

}

function pbench_perftest() {
	# TODO: Switchcase to either run
	# 1. e2e loggin soak ; --scale=$x
	# 2. scale test
	# 3. jctl
	
	pbench-register-tool-set --interval=10

	# register pbench on every node
	NODES=("$@")
	for NODE in ${NODES[@]}
	do
		echo "[*] Working on $NODE"
		pbench-register-tool-set --remote=$NODE --interval=10
		pbench-register-tool --name=pprof --remote=$NODE -- --osecomponent=node
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

cleanup() {
	: '
	TODO
	'
        echo 'Removing tmp files...'
        return $?
}

sig_handler() {
	: '
	User signal handler
	'

        tput bold; tput setf 4
        echo 'Received terminate signal. Exiting.'
        cleanup
        tput reset
        exit $ERR
}

print_char() {
	: '
	Prints a given character N times to stdout
	
	Parameters:
	$1 Character to print
	$2 Number of times to repeat

	example: print_char "*" 40
	'

        symbl=$1
        eval printf '%.0s${symbl}' {1..$2}
        echo
}

function usage() {
	echo '
	Accepted parameters::
	[*] are required

	-n <test name> [*]
	-e <e2e scale>
	-s <scale> 
	-j <journalctl>

	Examples: 
	./pbench_perftest.sh -n logging_e2e100_01012016 -e 100'
}
