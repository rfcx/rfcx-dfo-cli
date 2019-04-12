#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";
LOGS_DIR="$APP_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;
PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

# This script can be used to create cron entries

SCRIPT_NAME=$1
CRON_LOOP=$2

PARAM1=$3
PARAM2=$4
PARAM3=$5
PARAM4=$6

LOGFILEPATH="$LOGS_DIR/$SCRIPT_NAME.log";
SCRIPT_ID="$SCRIPT_NAME";
if [ "$SCRIPT_NAME" = "triggerd" ]; then 
	LOGFILEPATH="$LOGS_DIR/$PARAM1.log";
	SCRIPT_ID="$SCRIPT_NAME_$PARAM1";
	PARAM1="\"${PARAM1//\%/\\\%}\""
	PARAM3="\"${PARAM3//\%/\\\%}\""
	PARAM4="\"${PARAM4//\%/\\\%}\""
fi


if [ -f "$APP_DIR/${SCRIPT_NAME/-//}.sh" ]; then

	if [ ! -f "$PRIVATE_DIR/crontab_$SCRIPT_ID" ]; then 
		
		echo " - "
		read -p " - Would you like to set a recurring cron job for '$SCRIPT_ID'? (y/n): " -n 1 -r
		ALLOW_SET_CRONTAB="${REPLY}";

		if [ "$ALLOW_SET_CRONTAB" = "y" ]; then

			CRONJOB_EXEC="$APP_DIR/${SCRIPT_NAME/-//}.sh $PARAM1 $PARAM2 $PARAM3 $PARAM4 >> $LOGFILEPATH"

			CRON_USER=$(whoami)

			echo -e "$(sudo crontab -u $CRON_USER -l)\n*/$CRON_LOOP * * * * $CRONJOB_EXEC 2>&1" | sudo crontab -u $CRON_USER - 

			echo "'$SCRIPT_ID' script, by user '$CRON_USER', repeats every $CRON_LOOP minutes\n$CRONJOB_EXEC" > "$PRIVATE_DIR/crontab_$SCRIPT_ID"

		fi

	else

		CRON_CONFIG=`cat "$PRIVATE_DIR/crontab_$SCRIPT_NAME";`;

		echo ""; 
		echo " - cron job has already been set for '$SCRIPT_ID' script"
		# echo " - cron config: $CRON_CONFIG"

	fi

else

	echo "Error: No script for '$SCRIPT_NAME' could be found..."
fi
