#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;

FILEPATH_ORIG=$1

if [ -f "$DB_DIR/queue-queued.db" ]; then

	if [ -f "$FILEPATH_ORIG" ]; then

		QUEUED_AT_EPOCH=$(($($GNU_DATE_BIN '+%s')*1000))

		ADD_TO_QUEUE=$(sqlite3 "$DB_DIR/queue-queued.db" "INSERT INTO queued (queued_at, filepath, attempts) VALUES ($QUEUED_AT_EPOCH, '$FILEPATH_ORIG', 0);";)

	else

		echo " - File '$FILEPATH_ORIG' could not be found and was not added to queue..."
	
	fi

else
	echo " - "
	echo " - Database '$DB_DIR/queue-queued.db' could not be found..."
	echo " - File '$FILEPATH_ORIG' was not queued..."
	echo " - ."
fi
