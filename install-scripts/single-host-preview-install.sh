#!/bin/bash

function usage {
	echo "usage: $0 --help"
	echo "       $0 [-M] -a { install | start | stop | reset | status }"
	echo "       $0 -L {last-N-minutes-or-hours-spec}"
	echo "       $0 --update"
	# echo "usage: $0 [-c] -a <action>"
	# echo "    -c   run containers using docker-compose (default controls containers indivudally)
	if [ -n "$1" ]; then
		echo
		echo "  Initialize CodeStream, start & stop the services"
		echo "    -a   install | start | stop | reset | status"
		echo "    -M   do NOT control mongo container - use client supplied mongo service"
		echo "         set 'CS_MONGO_CONTAINER=ignore' to default the -M switch"
		echo
		echo "  Capture logs"
		echo "    -L   Nm | Nh, where N represents number of most recent minutes or hours to capture"
		echo "         eg. 1h - last hour of logs, 30m - last 30 minutes of logs"
	fi
	exit 1
}

function check_env {
	local rc=0
	[ -z "$HOME" ] && echo "\$HOME is not defined" >&2 && rc=1
	[ -z `which docker 2>/dev/null` ] && echo "'docker' command not found in search path" >&2 && rc=1
	# [ -z `which docker-compose 2>/dev/null` ] && echo "'docker-compose' command not found in search path" >&2 && rc=1
	[ -z `which curl 2>/dev/null` ] && echo "'curl' command not found in search path" >&2 && rc=1
	[ -z `which $TR_CMD 2>/dev/null` ] && echo "'$TR_CMD' command not found in search path" >&2 && rc=1
	echo $rc
}

function update_container_versions {
	curl -s --fail --output ~/.codestream/container-versions.new "$versionUrl"
	[ $? -ne 0 ] && echo "Failed to download container versions ($versionUrl)" && return 1
	x=`diff ~/.codestream/container-versions.new ~/.codestream/container-versions|wc -l`
	[ "$x" -eq 0 ] && echo "You are at the latest version" && /bin/rm -f ~/.codestream/container-versions.new && return 0
	/bin/mv -f ~/.codestream/container-versions.new ~/.codestream/container-versions
	return $?
}

function yesno {
	local prompt=$1
	local ans
	echo -n "$prompt"
	read ans
	while [ "$ans" != "y" -a "$ans" != "n" ]; do
		echo -n "y or n ? "
		read ans
	done
	[ $ans == "y" ] && return 1
	return 0
}

function random_string {
	local strLen=$1
	[ -z "$strLen" ] && strLen=18
	head /dev/urandom | $TR_CMD -dc A-Za-z0-9 | head -c $strLen ; echo ''
}

function container_state {
	local container=$1
	docker inspect --format='{{.State.Status}}' $container  2>/dev/null|grep -v '^[[:blank:]]*$'
}

function run_or_start_container {
	local container=$1
	local state=$(container_state $container)
	[ "$state" == "running" ] && echo "Container $container is already running" >&2 && return
	if [ "$state" == "exited" ]; then
		echo "docker start $container"
		docker start $container
		return
	fi
	[ -n "$state" ] && echo "Container $container is in an unknown state ($state). Aborting" >&2 && return
	echo "running container $container (docker run)"
	case $container in
	csmongo)
		docker run -d -P --network="host" --name csmongo --mount 'type=volume,source=csmongodata,target=/data' mongo:$mongoDockerVersion;;
	csrabbitmq)
		docker run -d -P --network="host" --name csrabbitmq teamcodestream/rabbitmq-onprem:$rabbitDockerVersion;;
	csbcast)
		docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csbcast teamcodestream/broadcaster-onprem:$broadcasterDockerVersion;;
	csapi)
		docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csapi teamcodestream/api-onprem:$apiDockerVersion;;
	csmailout)
		docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csmailout teamcodestream/mailout-onprem:$mailoutDockerVersion;;
	*)
		echo "don't know how to start container $container" >&2
		return;;
	esac
}

function start_containers {
	if [ $runMongo -eq 1 ]; then
		run_or_start_container csmongo
		sleep 5
	fi
	run_or_start_container csrabbitmq
	sleep 7
	run_or_start_container csbcast
	sleep 3
	run_or_start_container csapi
	run_or_start_container csmailout
}

function stop_containers {
	echo docker stop csapi csmailout csbcast csrabbitmq
	docker stop csapi csmailout csbcast csrabbitmq
	[ $runMongo -eq 1 ] && echo "docker stop csmongo" && docker stop csmongo
}

function remove_containers {
	echo docker rm csapi csmailout csbcast csrabbitmq
	docker rm csapi csmailout csbcast csrabbitmq
	[ $runMongo -eq 1 ] && echo "docker rm csmongo" && docker rm csmongo
}

function docker_status {
	docker ps -a|egrep -e '[[:blank:]]cs|NAME'
	echo
	docker volume ls -f name=csmongodata
}

function load_config_cache {
	[ -f ~/.codestream/config-cache ] && . ~/.codestream/config-cache
	[ -z "$FQHN" ] && FQHN=`hostname`
	local mailDomain=`echo $FQHN|cut -d. -f 2-`
	[ -z "$SECRET_AUTH" ] && SECRET_AUTH=$(random_string)
	[ -z "$SECRET_COOKIE" ] && SECRET_COOKIE=$(random_string)
	[ -z "$SECRET_CONFIRMATION_CHEAT" ] && SECRET_CONFIRMATION_CHEAT=$(random_string)
	[ -z "$SECRET_SUBSCRIPTION_CHEAT" ] && SECRET_SUBSCRIPTION_CHEAT=$(random_string)
	[ -z "$SECRET_MAIL" ] && SECRET_MAIL=$(random_string)
	[ -z "$SECRET_TELEMETRY" ] && SECRET_TELEMETRY=$(random_string)
	[ -z "$SECRET_BROADCAST_API" ] && SECRET_BROADCAST_API=$(random_string)
	[ -z "$SECRET_BROADCAST_AUTH" ] && SECRET_BROADCAST_AUTH=$(random_string)
	[ -z "$SENDER_EMAIL" ] && SENDER_EMAIL="codestream_alerts@$mailDomain"
	[ -z "$SUPPORT_EMAIL" ] && SUPPORT_EMAIL="codestream_support@$mailDomain"
}

function save_config_cache {
	echo -n "FQHN=$FQHN
SSL_CERT_FILE=$SSL_CERT_FILE
SSL_KEY_FILE=$SSL_KEY_FILE
SSL_CA_FILE=$SSL_CA_FILE
SECRET_AUTH=$SECRET_AUTH
SECRET_COOKIE=$SECRET_COOKIE
SECRET_CONFIRMATION_CHEAT=$SECRET_CONFIRMATION_CHEAT
SECRET_SUBSCRIPTION_CHEAT=$SECRET_SUBSCRIPTION_CHEAT
SECRET_MAIL=$SECRET_MAIL
SECRET_TELEMETRY=$SECRET_TELEMETRY
SECRET_BROADCAST_API=$SECRET_BROADCAST_API
SECRET_BROADCAST_AUTH=$SECRET_BROADCAST_AUTH
SENDER_EMAIL=$SENDER_EMAIL
SUPPORT_EMAIL=$SUPPORT_EMAIL
" > ~/.codestream/config-cache
}

function print_config_vars {
	echo "

Current configuration values:

	Fully qualified host name:       $FQHN
	SSL certificate file name:       $SSL_CERT_FILE
	SSL key file name:               $SSL_KEY_FILE
	SSL CA bundle file name:         $SSL_CA_FILE
	Email sender address:            $SENDER_EMAIL
	Support email address:           $SUPPORT_EMAIL

"
	# Auth secret:                     $SECRET_AUTH
	# Cookie secret:                   $SECRET_COOKIE
	# Confirmation secret:             $SECRET_CONFIRMATION_CHEAT
	# Subscription secret:             $SECRET_SUBSCRIPTION_CHEAT
	# Mail secret:                     $SECRET_MAIL
	# Telemetry secret:                $SECRET_TELEMETRY
	# Broadcast API secret:            $SECRET_BROADCAST_API
	# Broadcast auth secret:           $SECRET_BROADCAST_AUTH
}

function edit_config_vars {
	local newVal
	echo -n "Fully qualified host name ($FQHN): "; read newVal; [ -n "$newVal" ] && FQHN=$newVal
	echo -n "SSL certificate file name ($SSL_CERT_FILE): "; read newVal; [ -n "$newVal" ] && SSL_CERT_FILE=$newVal
	echo -n "SSL key file name ($SSL_KEY_FILE): "; read newVal; [ -n "$newVal" ] && SSL_KEY_FILE=$newVal
	echo -n "SSL CA bundle file name ($SSL_CA_FILE): "; read newVal; [ -n "$newVal" ] && SSL_CA_FILE=$newVal
	# echo -n "Auth secret ($SECRET_AUTH): "; read newVal; [ -n "$newVal" ] && SECRET_AUTH=$newVal
	# echo -n "Cookie secret ($SECRET_COOKIE): "; read newVal; [ -n "$newVal" ] && SECRET_COOKIE=$newVal
	# echo -n "Confirmation secret ($SECRET_CONFIRMATION_CHEAT): "; read newVal; [ -n "$newVal" ] && SECRET_CONFIRMATION_CHEAT=$newVal
	# echo -n "Subscription secret ($SECRET_SUBSCRIPTION_CHEAT): "; read newVal; [ -n "$newVal" ] && SECRET_SUBSCRIPTION_CHEAT=$newVal
	# echo -n "Mail secret ($SECRET_MAIL): "; read newVal; [ -n "$newVal" ] && SECRET_MAIL=$newVal
	# echo -n "Telemetry secret ($SECRET_TELEMETRY): "; read newVal; [ -n "$newVal" ] && SECRET_TELEMETRY=$newVal
	# echo -n "Broadcast API secret ($SECRET_BROADCAST_API): "; read newVal; [ -n "$newVal" ] && SECRET_BROADCAST_API=$newVal
	# echo -n "Broadcast auth secret ($SECRET_BROADCAST_AUTH): "; read newVal; [ -n "$newVal" ] && SECRET_BROADCAST_AUTH=$newVal
	echo -n "Email sender address ($SENDER_EMAIL): "; read newVal; [ -n "$newVal" ] && SENDER_EMAIL=$newVal
	echo -n "Support sender address ($SUPPORT_EMAIL): "; read newVal; [ -n "$newVal" ] && SUPPORT_EMAIL=$newVal
}

function validate_config_vars {
	local error=0
	[ -z "$SSL_CERT_FILE" ] && echo "SSL certificate file name required" && error=1
	[ -n "$SSL_CERT_FILE" -a ! -f ~/.codestream/$SSL_CERT_FILE ] && echo "SSL certificate ~/.codestream/$SSL_CERT_FILE not found" && error=1
	[ -z "$SSL_KEY_FILE" ] && echo "SSL key file name required" && error=1
	[ -n "$SSL_KEY_FILE" -a ! -f ~/.codestream/$SSL_KEY_FILE ] && echo "SSL key file ~/.codestream/$SSL_KEY_FILE not found" && error=1
	[ -z "$SSL_CA_FILE" ] && echo "SSL CA bundle file name required" && error=1
	[ -n "$SSL_CA_FILE" -a ! -f ~/.codestream/$SSL_CA_FILE ] && echo "SSL CA bundle file ~/.codestream/$SSL_CA_FILE not found" && error=1
	return $error
}

function create_config_from_template {
	local cfg_file=$1 cfg_template=$2
	cat $cfg_template \
	| sed -e "s/{{FQHN}}/$FQHN/g" \
	| sed -e "s/{{SSL_CERT_FILE}}/$SSL_CERT_FILE/g" \
	| sed -e "s/{{SSL_KEY_FILE}}/$SSL_KEY_FILE/g" \
	| sed -e "s/{{SSL_CA_FILE}}/$SSL_CA_FILE/g" \
	| sed -e "s/{{SENDER_EMAIL}}/$SENDER_EMAIL/g" \
	| sed -e "s/{{SUPPORT_EMAIL}}/$SUPPORT_EMAIL/g" \
	| sed -e "s/{{SECRET_AUTH}}/$SECRET_AUTH/g" \
	| sed -e "s/{{SECRET_COOKIE}}/$SECRET_COOKIE/g" \
	| sed -e "s/{{SECRET_CONFIRMATION_CHEAT}}/$SECRET_CONFIRMATION_CHEAT/g" \
	| sed -e "s/{{SECRET_SUBSCRIPTION_CHEAT}}/$SECRET_SUBSCRIPTION_CHEAT/g" \
	| sed -e "s/{{SECRET_MAIL}}/$SECRET_MAIL/g" \
	| sed -e "s/{{SECRET_TELEMETRY}}/$SECRET_TELEMETRY/g" \
	| sed -e "s/{{SECRET_BROADCAST_API}}/$SECRET_BROADCAST_API/g" \
	| sed -e "s/{{SECRET_BROADCAST_AUTH}}/$SECRET_BROADCAST_AUTH/g" \
	> $cfg_file
}

function capture_logs {
	local since=$1
	local logdir=cslogs$$
	local now=`date +%Y%m%d-%H%M%S`
	tmpDir=$HOME/$logdir
	mkdir $tmpDir
	docker logs --since $since csapi >$tmpDir/api.log 2>&1
	docker logs --since $since csbcast >$tmpDir/broadcaster.log 2>&1
	docker logs --since $since csrabbitmq >$tmpDir/rabbitmq.log 2>&1
	docker logs --since $since csmailout >$tmpDir/mailout.log 2>&1
	tar czpf $HOME/codestream-onprem-logs.$now.tgz -C $HOME $logdir
	[ -d "$tmpDir" ] && /bin/rm -rf $tmpDir
	ls -l $HOME/codestream-onprem-logs.$now.tgz
}

function install_and_configure {
	[ -f ~/.codestream/codestream-services-config.json ] && echo "~/.codestream/codestream-services-config.json already exists!" && exit 1

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
	echo

	[ ! -d ~/.codestream ] && echo "creating ~/.codestream" && mkdir ~/.codestream

	[ ! -f ~/.codestream/single-host-preview-minimal-cfg.json.template ] && echo "Fetching config file template..." && curl -s https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/config-templates/single-host-preview-minimal-cfg.json.template -o ~/.codestream/single-host-preview-minimal-cfg.json.template

	echo
	echo "Copy your 3 SSL certificate files (cert, key and CA bundle) to ~/.codestream/".
	echo
	echo -n "When you've done so, press ENTER to continue..."; read

	load_config_cache
	doLoop=1
	while [ $doLoop -eq 1 ]
	do
		edit_config_vars
		echo
		validate_config_vars
		if [ $? -eq 0 ]; then
			print_config_vars
			yesno "Are these values ok (y/n)? "
			[ $? -eq 1 ] && doLoop=0
		else
			echo
		fi
	done
	save_config_cache
	create_config_from_template ~/.codestream/codestream-services-config.json ~/.codestream/single-host-preview-minimal-cfg.json.template
	echo "

Your basic config file (~/.codestream/codestream-services-config.json) is ready.
Continue with the installation instructions. At a minimum, you will need to edit
the SMTP settings in the config file before you start the docker services.

"
}


[ $(check_env) -eq 1 ] && exit 1
[ "$1" == "--help" ] && usage help
[ "$1" == "--update" ] && update_container_versions && exit $?
[ `uname -s` == "Darwin" ] && TR_CMD=gtr || TR_CMD=tr
runMode=individual
action=""
[ "$CS_MONGO_CONTAINER" == "ignore" ] && runMongo=0 && echo "Mongo container will not be touched (CS_MONGO_CONTAINER=ignore)" || runMongo=1
logCapture=""
versionUrl="https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/versions/preview-single-host.ver"

# while getopts "ca:ML:" arg
while getopts "a:ML:" arg
do
	case $arg in
		L) logCapture=$OPTARG; action=sendLogs;;
		c) runMode=dockerCompose;;
		M) runMongo=0;;
		a) action=$OPTARG;;
		*) usage;;
	esac
done
shift `expr $OPTIND - 1`
[ -z "`echo $action | egrep -e '^(install|start|stop|reset|status|sendLogs)$'`" ] && echo "bad action" && usage


if [ ! -f ~/.codestream/container-versions ]; then
	curl -s --fail --output ~/.codestream/container-versions "$versionUrl"
	[ $? -ne 0 ] && echo "Failed to download container versions ($versionUrl)" && exit 1
fi
[ ! -f ~/.codestream/container-versions ] && echo "~/.codestream/container-versions not found" && exit 1
. ~/.codestream/container-versions || exit 1

case $action in
	sendLogs)
		capture_logs $logCapture;;
	install)
		install_and_configure;;
	reset)
		echo "Stopping and removing codestream containers..."
		stop_containers
		remove_containers;;
	start)
		echo "Starting codestream containers..."
		start_containers
		sleep 1
		docker_status;;
	status)
		docker_status;;
	stop)
		echo "Stopping codestream containers..."
		stop_containers;;
	*)
		usage;;
esac
exit 0
