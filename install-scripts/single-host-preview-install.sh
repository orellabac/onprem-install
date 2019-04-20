#!/bin/bash

function usage {
	echo "usage: $0 [-c] -a <action>"
	echo
	echo "    -a   run | start | stop | reset | install"
	echo "    -c   run containers using docker-compose (default controls containers indivudally)"
	exit 1
}

[ `uname -s` == "Darwin" ] && TR_CMD=gtr || TR_CMD=tr
runMode=individual
action=""
runMongo=1
while getopts "ca:M" arg
do
	case $arg in
		c) runMode=dockerCompose;;
		M) runMongo=0;;
		a) action=$OPTARG;;
		*) usage;;
	esac
done
shift `expr $OPTIND - 1`
[ -z `echo $action | egrep -e '^(run|start|stop|reset|install)$'` ] && echo "bad action" && usage

function check_env {
	local rc=0
	[ -z "$HOME" ] && echo "\$HOME is not defined" >&2 && rc=1
	[ -z `which docker 2>/dev/null` ] && echo "'docker' command not found in search path" >&2 && rc=1
	[ -z `which docker-compose 2>/dev/null` ] && echo "'docker-compose' command not found in search path" >&2 && rc=1
	[ -z `which curl 2>/dev/null` ] && echo "'curl' command not found in search path" >&2 && rc=1
	[ -z `which tr 2>/dev/null` ] && echo "'tr' command not found in search path" >&2 && rc=1
	echo $rc
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

function run_containers {
	if [ $runMongo -eq 1 ]; then
		echo "running mongo..."
		docker run -d -P --network="host" --name csmongo --mount 'type=volume,source=csmongodata,target=/data' mongo:3.4.9
		sleep 5
	fi
	echo "running rabbitMQ..."
	docker run -d -P --network="host" --name csrabbitmq teamcodestream/rabbitmq-onprem:0.0.0
	sleep 5
	#echo -n "Press ENTER..."; read
	echo "running broadcaster..."
	docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csbcast teamcodestream/broadcaster-onprem:0.0.0
	sleep 3
	#echo -n "Press ENTER..."; read
	echo "running api..."
	docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csapi teamcodestream/api-onprem:0.0.0
	#echo -n "Press ENTER..."; read
	echo "running outbound mail service..."
	docker run -d -P -v ~/.codestream:/opt/config --network="host" --name csmailout teamcodestream/mailout-onprem:0.0.0
}

function start_containers {
	if [ $runMongo -eq 1 ]; then
		echo "starting mongo...."
		docker start csmongo
		sleep 5
	fi
	echo "starting rabbitMQ..."
	docker start csrabbitmq
	sleep 7
	echo "starting broadcaster..."
	docker start csbcast
	sleep 3
	echo "starting api and outbound mail service..."
	docker start csapi csmailout
}

function stop_containers {
	docker stop csapi csmailout csbcast csrabbitmq
	[ $runMongo -eq 1 ] && docker stop csmongo
}

function remove_containers {
	docker rm csapi csmailout csbcast csrabbitmq
	[ $runMongo -eq 1 ] && docker rm csmongo
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


[ $(check_env) -eq 1 ] && exit 1

if [ $action == "reset" ]; then
	echo "Stopping and removing codestream containers..."
	stop_containers
	remove_containers
	exit 0
fi

if [ $action == "start" ]; then
	echo "Starting codestream containers..."
	start_containers
	exit 0
fi

if [ $action == "stop" ]; then
	echo "Stopping codestream containers..."
	stop_containers
	exit 0
fi

if [ $action == "run"  -a  $runMode == "individual" ]; then
	run_containers
	exit 0
fi

if [ $action == "install" ]; then
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
fi
