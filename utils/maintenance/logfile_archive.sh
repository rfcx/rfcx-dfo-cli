#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";

LOGS_DIR="$APP_DIR/logs"; if [ ! -d $LOGS_DIR/archive ]; then mkdir -p $LOGS_DIR/archive; fi;

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;
GNU_STAT_FLAG="-c%s"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_STAT_FLAG="-f%z"; fi;

echo " - "
echo " - Running Logfile maintenance..."

MAX_FILESIZE_KB=$((5*1024))

for LOG_FILEPATH in $LOGS_DIR/*; do

	if [ ! -d $LOG_FILEPATH ]; then

		LOG_FILESIZE_KB=$(($(($(stat $GNU_STAT_FLAG "$LOG_FILEPATH")))/1024))

		if [ "$LOG_FILESIZE_KB" -gt "$MAX_FILESIZE_KB" ]; then

			LOG_FILENAME=$(basename -- "$LOG_FILEPATH")
			CURRENT_DATE_PREFIX=$($GNU_DATE_BIN '+%Y%m%d-%H%M%S')
			NEW_LOG_FILEPATH="$LOGS_DIR/archive/$CURRENT_DATE_PREFIX-$LOG_FILENAME"

			echo " - Archiving '$LOG_FILENAME' ($LOG_FILESIZE_KB kB)"
			mv $LOG_FILEPATH $NEW_LOG_FILEPATH && touch $LOG_FILEPATH && gzip -c $NEW_LOG_FILEPATH > $NEW_LOG_FILEPATH.gz && rm $NEW_LOG_FILEPATH;

		fi

	fi

done
