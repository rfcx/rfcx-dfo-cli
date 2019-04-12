#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
UTILS_DIR="$APP_DIR/utils"; if [ ! -d $UTILS_DIR ]; then mkdir -p $UTILS_DIR; fi;

echo " - "
echo " - Setup: Started"
echo " - "

if [ -d "$APP_DIR/.git" ]; then 

	echo " - Blocking update process because this is a Git repository.";
	echo " - "

else

	# Download 'upgrade' script
	if [ ! -f "$UTILS_DIR/upgrade.sh" ]; then
		DOWNLOAD=$(wget -q -O "$UTILS_DIR/upgrade.sh" "https://raw.githubusercontent.com/rfcx/rfcx-guardian-cli/master/utils/upgrade.sh");
		chmod a+x "$UTILS_DIR/upgrade.sh";
	fi

	echo " - Running Update script"
	echo " - "
	$UTILS_DIR/upgrade.sh "update" && $APP_DIR/update.sh
	echo " - "

	##############################
	## Initialize Guardian credentials (if necessary)
	$UTILS_DIR/setup/create_credentials.sh
	##############################

	##############################
	## Register with RFCx API (if necessary)
	$UTILS_DIR/setup/api_register.sh
	##############################





	echo " - "
	echo " - Creating database files, if they don't already exist..."
	$APP_DIR/utils/database_init.sh "checkins-queued"
	$APP_DIR/utils/database_init.sh "checkins-sent"
	$APP_DIR/utils/database_init.sh "checkins-complete"

	# set cron jobs
	if [ -f "$APP_DIR/utils/crontab.sh" ]; then
		$APP_DIR/utils/crontab.sh "update" 20
		$APP_DIR/utils/crontab.sh "triggerd" 1 "checkin_from_queue" 60 "SCW1840_%Y%Y%m%d_%H%M%S"
		$APP_DIR/utils/crontab.sh "triggerd" 1 "queue_from_inotify" 60 "/var/www/sites/Sand_Heads/" "wav"
	fi

fi


echo " - "
echo " - Setup: Complete"
echo " - "
