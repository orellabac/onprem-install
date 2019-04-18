#!/bin/bash

function usage {
	echo "usage: $0 [-c] -a <action>"
	echo
	echo "    -a   run | start | stop | reset | install"
	echo "    -c   run containers using docker-compose (default controls containers indivudally)"
	exit 1
}

function check_env {
	local rc=0
	[ -z "$HOME" ] && echo "\$HOME is not defined" >&2 && rc=1
	[ -z `which docker 2>/dev/null` ] && echo "'docker' command not found in search path" >&2 && rc=1
	[ -z `which docker-compose 2>/dev/null` ] && echo "'docker-compose' command not found in search path" >&2 && rc=1
	[ -z `which curl 2>/dev/null` ] && echo "'curl' command not found in search path" >&2 && rc=1
	echo $rc
}

function run_containers {
	echo "running rabbitMQ..."
	docker run -d -P --network="host" --name csrabbitmq teamcodestream/rabbitmq-onprem:0.0.0
	sleep 7
	echo "running broadcaster..."
	docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csbcast teamcodestream/broadcaster-onprem:0.0.0
	sleep 7
	echo "running api..."
	docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csapi teamcodestream/api-onprem:0.0.0
	echo "running outbound mail service..."
	docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csmailout teamcodestream/mailout-onprem:0.0.0
}

function start_containers {
	echo "starting rabbitMQ..."
	docker start csrabbitmq
	sleep 7
	echo "starting broadcaster..."
	docker start csbcast
	sleep 7
	echo "starting api and outbound mail service..."
	docker start csapi csmailout
}

function stop_containers {
	docker stop csapi csmailout csbcast csrabbitmq
}

function remove_containers {
	docker rm csapi csmailout csbcast csrabbitmq
}

runMode=individual
action=""
while getopts "ca:" arg
do
	case $arg in
		c) runMode=dockerCompose;;
		a) action=$OPTARG;;
		*) usage;;
	esac
done
shift `expr $OPTIND - 1`
[ -z `echo $action | egrep -e '^(run|start|stop|reset|install)$'` ] && echo "bad action" && usage

[ $(check_env) -eq 1 ] && exit 1

if [ $action == "reset" ]; then
	echo "Stopping and removing codestream containers..."
	stop_containers
	remove_containers
	exit 0
fi

if [ $action == "start" ]; then
	echo "Stopping and removing codestream containers..."
	start_containers
	exit 0
fi

if [ $action == "run"  -a  $runMode == "individual" ]; then
	run_containers
	exit 0
fi

exit 0

echo -n "
This script will install the single-host-preview version of CodeStream OnPrem.
It runs services in docker containers on a single host.

You will need to perform some external work and update the codestream config file
before any of the services can be launched.

This script will walk you through all that.  On this host, the only modifications
made will be the creation of a ~/.codestream/ directory and a number of config
files placed in it.  Everything else will be inside of docker containers and/or
docker volumes.

Press ENTER when you are ready to proceed..."
read

[ ! -d ~/.codestream ] && echo "creating ~/.codestream" && mkdir ~/.codestream
