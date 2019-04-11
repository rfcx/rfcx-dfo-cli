#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";

LOGS_DIR="$SCRIPT_DIR/logs"; if [ ! -d $LOGS_DIR/archive ]; then mkdir -p $LOGS_DIR/archive; fi;

GNU_STAT_FLAG="-c%s"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_STAT_FLAG="-f%z"; fi;

echo " - "
echo " - We archive log files here, if they're getting too big..."

for LOG_FILEPATH in $LOGS_DIR/*.log; do

	LOG_FILESIZE=$(($(($(stat $GNU_STAT_FLAG "$LOG_FILEPATH")))/1024))
	echo " - $LOG_FILEPATH - $LOG_FILESIZE"

done
