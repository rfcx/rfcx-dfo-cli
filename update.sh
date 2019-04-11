#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
PRIVATE_DIR="$SCRIPT_DIR/.private"

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;
NOW=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))

if [ ! -d "$SCRIPT_DIR/.git" ]; then 

	$SCRIPT_DIR/utils/upgrade.sh "checkin"
	$SCRIPT_DIR/utils/upgrade.sh "stdin"
	$SCRIPT_DIR/utils/upgrade.sh "setup"
	$SCRIPT_DIR/utils/upgrade.sh "update"
	$SCRIPT_DIR/utils/upgrade.sh "queue"
	$SCRIPT_DIR/utils/upgrade.sh "trigger_checkin_from_queue"
	$SCRIPT_DIR/utils/upgrade.sh "trigger_queue_from_inotify"
	$SCRIPT_DIR/utils/upgrade.sh "trigger_queue_from_directory"
	$SCRIPT_DIR/utils/upgrade.sh "triggerd"
	$SCRIPT_DIR/utils/upgrade.sh "utils-crontab"
	$SCRIPT_DIR/utils/upgrade.sh "utils-upgrade"
	$SCRIPT_DIR/utils/upgrade.sh "utils-json_parse"
	$SCRIPT_DIR/utils/upgrade.sh "utils-database_init"

else

	echo " - Blocking update process because this is a Git repository.";

fi


if [ -f "$PRIVATE_DIR/hostname" ]; then 
	
	GUID=`cat "$PRIVATE_DIR/guid";`;
	TOKEN=`cat "$PRIVATE_DIR/token";`;
	HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;
	
	echo " - ";
	echo " - Sending Diagnostic CheckIn to $HOSTNAME..."
	curl -s -o /dev/null -X GET "$HOSTNAME/v1/guardians/$GUID/software/all?role=updater&version=0.4.0&battery=100&timestamp=$NOW" -H "Cache-Control: no-cache" -H "x-auth-user: guardian/$GUID" -H "x-auth-token: $TOKEN";	

fi

