#!/bin/bash

function usage {
	local cmd=`basename $0`
	echo "usage: $cmd --help"
	echo "       $cmd [-M] -a { install | start | stop | reset | status | start_mongo }"
	echo "       $cmd --logs {Nh | Nm}                 # collect last N hours or minutes of logs"
	echo "       $cmd --update-containers [--no-start] # grab latest container versions (performs backup)"
	echo "       $cmd --update-myself                  # update the single-host-preview-install.sh script [and utilities]"
	echo "       $cmd --backup                         # backup mongo database"
	echo "       $cmd --restore {latest | <file>}      # restore mongo database from latest backup or <file>"
	echo "       $cmd --undo-stack                     # print the undo stack"
	if [ "$1" == help ]; then
		echo
		echo "  Initialization of CodeStream and container control (-a)"
		echo "      install   create the config file and prepare the CodeStream environment"
		echo "      start     run or start the CodeStream containers"
		echo "      stop      stop the CodeStream containers"
		echo "      reset     stop and remove the containers"
		echo "                *** mongo data _should_ persist a mongo container reset, but ***"
		echo "                *** make sure you back up the data with --backup first.      ***"
		echo "      status    check the docker status of the containers"
		echo
		echo "      Note: specify -M or set environment variable CS_MONGO_CONTAINER=ignore to exclude"
		echo "      mongo when running the commands above"
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

function fetch_utilities {
	local force_fl="$1"
	[ ! -d ~/.codestream/util ] && mkdir ~/.codestream/util
	for u in dt-merge-json
	do
		if [ ! -f ~/.codestream/$u -o -n "$force_fl" ]; then
			# echo "Fetching $u ..."
			curl https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/install-scripts/util/$u -o ~/.codestream/util/$u -s
			[ $? -ne 0 ] && echo "error fetching $u" && exit 1
			chmod 750 ~/.codestream/util/$u
		fi
	done
}

function update_myself {
	fetch_utilities --force
	(
		curl https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/install-scripts/single-host-preview-install.sh -o ~/.codestream/single-host-preview-install.sh -s
		chmod +x ~/.codestream/single-host-preview-install.sh
	)
	exit 0
}

# returns:
#   0   successfully updated
#   1   no update necessary
#   2   error during update
function update_container_versions {
	local undoId="$1"
	curl -s --fail --output ~/.codestream/container-versions.new "$versionUrl$versionSufx"
	[ $? -ne 0 ] && echo "Failed to download container versions ($versionUrl$versionSufx)" && return 2
	if [ ! -f ~/.codestream/container-versions ]; then
		/bin/mv ~/.codestream/container-versions.new ~/.codestream/container-versions || return 2
		return 0
	fi
	x=`diff ~/.codestream/container-versions.new ~/.codestream/container-versions|wc -l`
	[ "$x" -eq 0 ] && /bin/rm -f ~/.codestream/container-versions.new && return 1
	[ -z "$undoId" ] && undoId=$(undo_stack_id "" "called update container versions()")
	/bin/mv -f ~/.codestream/container-versions ~/.codestream/.undo/$undoId/container-versions || return 2
	/bin/mv -f ~/.codestream/container-versions.new ~/.codestream/container-versions || return 2
	return 0
}

function load_container_versions {
	local undoId="$1"
	[ ! -f ~/.codestream/container-versions ] && { update_container_versions "$undoId" "called load_container_versions()" || exit 1; }
	. ~/.codestream/container-versions || exit 1
}

function get_config_file_template {
	local undoId="$1"
	if [ -f ~/.codestream/single-host-preview-minimal-cfg.json.template ]; then
		[ -z "$undoId" ] && undoId=$(undo_stack_id "" "called get_config_file_template()")
		cp -p ~/.codestream/single-host-preview-minimal-cfg.json.template ~/.codestream/.undo/$undoId/single-host-preview-minimal-cfg.json.template
	fi
	echo "Fetching config file template..."
	curl -s https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/config-templates/single-host-preview-minimal-cfg.json.template -o ~/.codestream/single-host-preview-minimal-cfg.json.template || { echo "error gett config template" >&2; exit 1; }
	chmod 660 ~/.codestream/single-host-preview-minimal-cfg.json.template || exit 1
}

function update_config_file {
	local undoId="$1"
	[ -z "$undoId" ] && undoId=$(undo_stack_id "" "called update_config_file()")
	# backup config file & template and get new template
	cp -p ~/.codestream/codestream-services-config.json ~/.codestream/.undo/$undoId/codestream-services-config.json
	get_config_file_template $undoId
	# update config file with new template data
	run_python_script /cs/util/dt-merge-json --existing-file /cs/.undo/$undoId/codestream-services-config.json --new-file /cs/single-host-preview-minimal-cfg.json.template >~/.codestream/codestream-services-config.json.new
	if [ $rc -ne 0 -o ! -s ~/.codestream/codestream-services-config.json.new ]; then
		echo "There was a problem updating the config file!!!" >&2
		/bin/rm -f ~/.codestream/codestream-services-config.json.new
		exit 1
	fi
	/bin/mv -f ~/.codestream/codestream-services-config.json.new ~/.codestream/codestream-services-config.json
}

function update_containers_except_mongo {
	local nostart="$1"
	local undoId=$(undo_stack_id "" "full container update procedure")
	backup_dot_codestream $undoId
	stop_containers 0
	backup_mongo $FQHN $undoId || exit 1
	remove_containers 0
	update_container_versions $undoId
	local rc=$?
	[ $rc -eq 2 ] && echo "error updating containers">&2 && exit 1
	if [ $rc -eq 0 ]; then
		load_container_versions $undoId
		update_config_file $undoId
	else
		echo "You are already running the latest container versions"
	fi
	[ -z "$nostart" ] && start_containers 0
}

function undo_stack_id {
	local undoId="$1"
	local eventDesc="$2"
	[ -z "$eventDesc" ] && eventDesc="no description"
	if [ "$undoId" == latest ]; then
		undoId=`(cd ~/.codestream/.undo && /bin/ls |tail -1)`
	elif [ -z "$undoId" ]; then
		undoId=`date '+%Y-%m-%d_%H-%M-%S'`
	fi
	[ ! -d ~/.codestream/.undo/$undoId ] && mkdir -p ~/.codestream/.undo/$undoId
	echo "$eventDesc" >~/.codestream/.undo/$undoId/description
	echo $undoId
}

function print_undo_stack {
	[ ! -d ~/.codestream/.undo ] && echo "the undo stack is empty" >&2 && return
	for u in `ls ~/.codestream/.undo`; do
		echo "  $u   `cat ~/.codestream/.undo/$u/description`"
	done
}

function backup_dot_codestream {
	local undoId="$1"
	[ -z "$undoId" ] && undoId=$(undo_stack_id "" "called backup_dot_codestream()")
	tar -C ~/.codestream -czpf ~/.codestream/.undo/$undoId/dot.codestream.tgz  --exclude='backups*' --exclude='.undo*' --exclude='log-capture*' .
}

function backup_mongo {
	local host="$1"
	local undoId="$2"
	[ ! -d ~/.codestream/backups ] && mkdir ~/.codestream/backups
	local filename="dump_$(date '+%Y-%m-%d_%H-%M-%S').gz"
	# echo "docker run --rm mongo:$mongoDockerVersion mongodump --host $host --archive --gzip"
	# docker run --rm mongo:$mongoDockerVersion mongodump --host $host --archive --gzip | cat > ~/.codestream/backups/$filename
	docker run --rm --network=host mongo:$mongoDockerVersion mongodump --host localhost --archive --gzip | cat > ~/.codestream/backups/$filename
	[ $? -ne 0 -o \( ! -s ~/.codestream/backups/$filename \) ] && echo "backup failed" >&2 && return 1
	echo "Backed up $host to ~/.codestream/backups/$filename"
	return 0
}

function restore_mongo {
	local host=$1 file=$2 prompt=$3
	[ -z "$file" ] && echo "usage: restore_mongo(host file)" >&2 && return 1
	[ ! -f "$file" ] && echo "$file not found" >&2 && return 1
	echo "Restoring data from $file"
	echo -e "
  ***  WARNING   WARNING   WARNING  ***

  This will overwrite the data currently in mongo and replace it with the
  data from the backup file. The data currently in mongo will be lost!!
"
	if [ "$prompt" != no ]; then
		yesno "Do you want to proceed (y/N)? "
		[ $? -eq 0 ] && echo "never mind" && return 1
	fi
	# cat $file | docker run --rm -i mongo:$mongoDockerVersion mongorestore --host $host --archive --gzip --drop
	cat $file | docker run --rm -i --network=host mongo:$mongoDockerVersion mongorestore --host localhost --archive --gzip --drop
	[ $? -ne 0 ] && echo "error restoring data!!" >&2 && return 1
	return 0
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

# this reports results to stdout so redirect other msgs to stderr
function run_python_script {
	# echo "docker run --rm  --network=host -v ~/.codestream:/cs teamcodestream/dt-python3:$dtPython3DockerVersion $*" >&2
	docker run --rm  --network=host -v ~/.codestream:/cs teamcodestream/dt-python3:$dtPython3DockerVersion $*
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
		# echo "docker start $container"
		docker start $container
		return
	fi
	[ -n "$state" ] && echo "Container $container is in an unknown state ($state). Aborting" >&2 && return
	echo "running container $container (docker run)"
	case $container in
	csmongo)
		echo docker run -d -P --network="host" --name csmongo --mount 'type=volume,source=csmongodata,target=/data' mongo:$mongoDockerVersion
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
	local runMongoFlag=$1
	[ -z "$runMongoFlag" ] && runMongoFlag=$runMongo
	if [ $runMongoFlag -eq 1 ]; then
		run_or_start_container csmongo
		sleep 5
	fi
	echo "Starting containuers..."
	run_or_start_container csrabbitmq
	sleep 7
	run_or_start_container csbcast
	sleep 3
	run_or_start_container csapi
	run_or_start_container csmailout
}

function stop_containers {
	local runMongoFlag=$1
	local c
	local state
	[ -z "$runMongoFlag" ] && runMongoFlag=$runMongo
	local containers="csapi csmailout csbcast csrabbitmq"
	[ $runMongoFlag -eq 1 ] && containers="$containers csmongo"
	echo "Stopping containers..."
	for c in $containers
	do
		state=$(container_state $c)
		# echo "container $c state: $state"
		if [ "$state" == "running" ]; then
			docker stop $c
		elif [ "$state" == "exited" ]; then
			echo "container $c is not running "
		elif [ -z "$state" ]; then
			echo "container $c not found - nothing to stop"
		else
			echo "container $c is in an unknown state ($state)"
		fi
	done
}

function remove_containers {
	local runMongoFlag=$1
	[ -z "$runMongoFlag" ] && runMongoFlag=$runMongo
	# echo docker rm csapi csmailout csbcast csrabbitmq
	# docker rm csapi csmailout csbcast csrabbitmq
	local containers="csapi csmailout csbcast csrabbitmq"
	[ $runMongoFlag -eq 1 ] && containers="$containers csmongo"
	echo "Removing containers..."
	for c in $containers
	do
		state=$(container_state $c)
		# echo "state of $c is $state"
		if [ "$state" == "exited" ]; then
			# echo "docker rm $c"
			docker rm $c
		elif [ -z "$state" ]; then
			echo "container $c not found - nothing to remove"
		else
			echo "container $c is in an unexpected state ($state)"
		fi
	done
	# [ $runMongoFlag -eq 1 ] && echo "docker rm csmongo" && docker rm csmongo
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
	| sed -e "s/{{SECRET_BROADCAST_API}}/$SECRET_BROADCAST_API/g" \
	| sed -e "s/{{SECRET_BROADCAST_AUTH}}/$SECRET_BROADCAST_AUTH/g" \
	> $cfg_file
}

function capture_logs {
	local since=$1
	[ -z "$since" ] && echo "bad usage: missing hours or minutes spec" && exit 1
	[ ! -d ~/.codestream/log-capture ] && mkdir ~/.codestream/log-capture
	local logdir=cslogs$$
	local now=`date +%Y%m%d-%H%M%S`
	tmpDir=$HOME/$logdir
	mkdir $tmpDir
	docker logs --since $since csapi >$tmpDir/api.log 2>&1
	docker logs --since $since csbcast >$tmpDir/broadcaster.log 2>&1
	docker logs --since $since csrabbitmq >$tmpDir/rabbitmq.log 2>&1
	docker logs --since $since csmailout >$tmpDir/mailout.log 2>&1
	tar -czpf ~/.codestream/log-capture/codestream-onprem-logs.$now.tgz -C $HOME $logdir
	[ -d "$tmpDir" ] && /bin/rm -rf $tmpDir
	ls -l ~/.codestream/log-capture/codestream-onprem-logs.$now.tgz
}

function install_and_configure {
	[ -f ~/.codestream/codestream-services-config.json ] && echo "~/.codestream/codestream-services-config.json already exists!">&2 && exit 1

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
	[ ! -f ~/.codestream/single-host-preview-minimal-cfg.json.template ] && get_config_file_template

	echo
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


[ `uname -s` == "Darwin" ] && TR_CMD=gtr || TR_CMD=tr
runMode=individual
action=""
versionUrl="https://raw.githubusercontent.com/TeamCodeStream/onprem-install/master/versions/preview-single-host.ver"
[ -f ~/.codestream/version-suffix ] && versionSufx=".`cat ~/.codestream/version-suffix`" || versionSufx=""
[ -n "$versionSufx" ] && echo "using file suffix $versionSufx"
logCapture=""
[ "$CS_MONGO_CONTAINER" == "ignore" ] && runMongo=0 || runMongo=1
[ -f ~/.codestream/config-cache ] && . ~/.codestream/config-cache

[ $(check_env) -eq 1 ] && exit 1
[ "$1" == "--help" -o -z "$1" ] && usage help
[ "$1" == "--update-myself" ] && update_myself "$2" && exit 0
[ "$1" == "--undo-stack" ] && print_undo_stack && exit 0

fetch_utilities
load_container_versions

[ "$1" == "--update-containers" ] && { update_containers_except_mongo "$2"; exit $?; }
[ "$1" == "--logs" ] && capture_logs "$2" && exit 0
[ "$1" == "--backup" ] && backup_mongo $FQHN && exit $?
if [ "$1" == "--restore" ]; then
	[ "$2" == latest ] && { restore_mongo $FQHN "$(/bin/ls ~/.codestream/backups/dump_*.gz | tail -1)"; exit $?; }
	restore_mongo $FQHN $2
	exit $?
fi

# while getopts "ca:ML:" arg
while getopts "a:ML:" arg
do
	case $arg in
		L) capture_logs $OPTARG; exit 0;;
		c) runMode=dockerCompose;;
		M) runMongo=0;;
		a) action=$OPTARG;;
		*) usage;;
	esac
done
shift `expr $OPTIND - 1`
[ -z "`echo $action | egrep -e '^(install|start|start_mongo|stop|reset|status)$'`" ] && echo "bad action" && usage


[ $runMongo -eq 0 ] && echo "Mongo container will not be touched (CS_MONGO_CONTAINER=ignore)"

case $action in
	install)
		install_and_configure;;
	reset)
		echo "Stopping and removing codestream containers..."
		stop_containers
		remove_containers;;
	start)
		start_containers
		sleep 1
		docker_status;;
	start_mongo)
		run_or_start_container csmongo
		sleep 2
		docker_status;;
	status)
		docker_status;;
	stop)
		stop_containers;;
	*)
		usage;;
esac
exit 0
