#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
PRIVATE_DIR="$APP_DIR/.private"

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;
NOW=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))

if [ -d "$APP_DIR/.git" ]; then 

	echo " - "
	echo " - Blocking update process because this is a Git repository.";

else

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
	$APP_DIR/utils/upgrade.sh "utils-stdin"
	$APP_DIR/utils/upgrade.sh "utils-upgrade"
	$APP_DIR/utils/upgrade.sh "utils-checkin-checkin_json_build"
	$APP_DIR/utils/upgrade.sh "utils-setup-create_credentials"
	$APP_DIR/utils/upgrade.sh "utils-setup-api_register"
	$APP_DIR/utils/upgrade.sh "utils-maintenance-logfile_archive"
	$APP_DIR/utils/upgrade.sh "utils-maintenance-api_update_checkin"

fi

##############################
## Send Update CheckIn to RFCx API
$APP_DIR/utils/maintenance/api_update_checkin.sh
##############################


#######################
# log archive check
$APP_DIR/utils/maintenance/logfile_archive.sh
##############################



##############################
# let's remove this section ASAP
if [ ! -f "$PRIVATE_DIR/api_token" ]; then cp "$PRIVATE_DIR/token" "$PRIVATE_DIR/api_token"; fi;
if [ ! -f "$PRIVATE_DIR/api_hostname" ]; then cp "$PRIVATE_DIR/hostname" "$PRIVATE_DIR/api_hostname"; fi;
if [ ! -f "$PRIVATE_DIR/api_registered" ]; then cp "$PRIVATE_DIR/registered" "$PRIVATE_DIR/api_registered"; fi;
if [ ! -f "$PRIVATE_DIR/guardian_guid" ]; then cp "$PRIVATE_DIR/guid" "$PRIVATE_DIR/guardian_guid"; fi;
##############################







