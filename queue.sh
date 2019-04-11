#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;

FILEPATH_ORIG=$1

echo " - "
echo " - File '$FILEPATH_ORIG'..."

if [ -f "$DB_DIR/checkins-queued.db" ]; then
	
	if [ -f "$FILEPATH_ORIG" ]; then

		QUEUED_AT_EPOCH=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))

		ADD_TO_QUEUE=$(sqlite3 "$DB_DIR/checkins-queued.db" "INSERT INTO queued (queued_at, filepath, attempts) VALUES ($QUEUED_AT_EPOCH, '$FILEPATH_ORIG', 0);";)

		VERIFY_QUEUE_ENTRY=$(sqlite3 "$DB_DIR/checkins-queued.db" "SELECT queued_at FROM queued WHERE filepath='$FILEPATH_ORIG';";)

		if [ "$VERIFY_QUEUE_ENTRY" = "$QUEUED_AT_EPOCH" ]; then 
			echo " - ...was SUCCESSFULLY added to the queue..."
		else
			echo " - ...could NOT be added to queue..."
			echo " - Specific error unknown..."
		fi

	else

		echo " - ...could not be found on the filesystem and was NOT added to queue..."
	
	fi

else
	echo " - ...was NOT queued because database '$DB_DIR/checkins-queued.db' could not be found"
fi

echo " - "
