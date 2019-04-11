#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";

LOGS_DIR="$SCRIPT_DIR/logs"; if [ ! -d $LOGS_DIR/archive ]; then mkdir -p $LOGS_DIR/archive; fi;

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;
GNU_STAT_FLAG="-c%s"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_STAT_FLAG="-f%z"; fi;

echo " - "
echo " - Running Logfile maintenance..."

# MAX_FILESIZE_KB=$((5*1024))
MAX_FILESIZE_KB=$((1*140))

for LOG_FILEPATH in $LOGS_DIR/*.log; do

	LOG_FILESIZE_KB=$(($(($(stat $GNU_STAT_FLAG "$LOG_FILEPATH")))/1024))

	if [ "$LOG_FILESIZE_KB" -gt "$MAX_FILESIZE_KB" ]; then

		LOG_FILENAME=$(basename -- "$LOG_FILEPATH")

		NEW_LOG_FILEPATH="$LOGS_DIR/archive/XXXX-XX-XX-$LOG_FILENAME.log"

		mv $LOG_FILEPATH $NEW_LOG_FILEPATH && touch $LOG_FILEPATH;

	fi

done
