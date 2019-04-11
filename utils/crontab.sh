#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
LOGS_DIR="$SCRIPT_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;
PRIVATE_DIR="$SCRIPT_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

# This script can be used to create cron entries

SCRIPT_NAME=$1
CRON_LOOP=$2

EXEC_PARAM_1=$3
EXEC_PARAM_2=$4
EXEC_PARAM_3=$5
EXEC_PARAM_4=$6

LOGFILEPATH="$LOGS_DIR/$SCRIPT_NAME.log";
if [ "$SCRIPT_NAME" = "triggerd" ]; then LOGFILEPATH="$LOGS_DIR/$EXEC_PARAM_1.log"; fi;

if [ -f "$SCRIPT_DIR/${SCRIPT_NAME/-//}.sh" ]; then

	if [ ! -f "$PRIVATE_DIR/crontab_$SCRIPT_NAME" ]; then 
		
		echo ""; echo " - "
		read -p " - Would you like to set a recurring cron job for '$SCRIPT_NAME'? (y/n): " -n 1 -r
		ALLOW_SET_CRONTAB="${REPLY}";

		CRON_USER=$(whoami)

		echo ""; echo " - "

		if [ "$ALLOW_SET_CRONTAB" = "y" ]; then

			CRONJOB_EXEC="$SCRIPT_DIR/${SCRIPT_NAME/-//}.sh $EXEC_PARAM_1 $EXEC_PARAM_2 $EXEC_PARAM_3 $EXEC_PARAM_4 >> $LOGFILEPATH"

			echo -e "$(sudo crontab -u $CRON_USER -l)\n*/$CRON_LOOP * * * * $CRONJOB_EXEC 2>&1" | sudo crontab -u $CRON_USER - 

			echo "'$SCRIPT_NAME.sh' script, by user '$CRON_USER', repeats every $CRON_LOOP minutes" > "$PRIVATE_DIR/crontab_$SCRIPT_NAME"

		fi

	else

		CRON_CONFIG=`cat "$PRIVATE_DIR/crontab_$SCRIPT_NAME";`;

		echo ""; 
		echo " - cron job has already been set for '$SCRIPT_NAME' script"
		echo " - cron config: $CRON_CONFIG"

	fi

else

	echo "Error: No script for '$SCRIPT_NAME' could be found..."
fi
