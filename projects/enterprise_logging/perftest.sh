#!/usr/bin/env bash

SCRIPTNAME=$(basename ${0%.*})
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
UTILS=$SCRIPTDIR/utils
source $UTILS/functions.sh

KUBEREPO=$2
NODELIST=("192.1.11.83 192.1.11.226 192.1.11.66")

parse_opts $@
check_required $@

setup_globals $KUBEREPO 
clean_pbench
perftest ${NODELIST[@]}
[[ $? -eq 0 ]] && exit 0 || exit 1
