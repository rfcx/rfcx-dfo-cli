#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$APP_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
PRIVATE_DIR="$APP_DIR/.private"

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;
NOW=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))

if [ ! -d "$APP_DIR/.git" ]; then 

	$APP_DIR/utils/upgrade.sh "checkin"
	$APP_DIR/utils/upgrade.sh "queue"
	$APP_DIR/utils/upgrade.sh "setup"
	$APP_DIR/utils/upgrade.sh "trigger_checkin_from_queue"
	$APP_DIR/utils/upgrade.sh "trigger_queue_from_inotify"
	$APP_DIR/utils/upgrade.sh "trigger_queue_from_directory"
	$APP_DIR/utils/upgrade.sh "triggerd"
	$APP_DIR/utils/upgrade.sh "update"
	$APP_DIR/utils/upgrade.sh "utils-crontab"
	$APP_DIR/utils/upgrade.sh "utils-database_init"
	$APP_DIR/utils/upgrade.sh "utils-json_parse"
	$APP_DIR/utils/upgrade.sh "utils-log_archive"
	$APP_DIR/utils/upgrade.sh "utils-stdin"
	$APP_DIR/utils/upgrade.sh "utils-upgrade"
	$APP_DIR/utils/upgrade.sh "utils-checkin-checkin_json_build"

else

	echo " - Blocking update process because this is a Git repository.";

fi


if [ -f "$PRIVATE_DIR/hostname" ]; then 
	
	GUID=`cat "$PRIVATE_DIR/guid";`;
	TOKEN=`cat "$PRIVATE_DIR/token";`;
	HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;
	
	echo " - ";
	echo " - Sending Diagnostic CheckIn to $HOSTNAME..."
	curl -s -o /dev/null -X GET "$HOSTNAME/v1/guardians/$GUID/software/all?role=updater-cli&version=0.1.0&battery=100&timestamp=$NOW" -H "Cache-Control: no-cache" -H "x-auth-user: guardian/$GUID" -H "x-auth-token: $TOKEN";	

fi

# log archive check
$APP_DIR/utils/log_archive.sh

if [ ! -f "$PRIVATE_DIR/software_version" ]; then 
	SOFTWARE_VERSION="0.1.0"
	echo "$SOFTWARE_VERSION" > "$PRIVATE_DIR/software_version"
else
	SOFTWARE_VERSION=`cat "$PRIVATE_DIR/software_version";`;
fi

