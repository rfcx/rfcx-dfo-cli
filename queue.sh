#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;

FILEPATH_ORIG=$1

if [ ! -z "$FILEPATH_ORIG" -a "$FILEPATH_ORIG" != " " ]; then

	# echo " - "
	echo " - File '$FILEPATH_ORIG'..."

	if [ -f "$DB_DIR/checkins-queued.db" ]; then
		
		if [ -f "$FILEPATH_ORIG" ]; then

			QUEUED_AT_EPOCH=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))

			# ADD_TO_QUEUE=$(sqlite3 "$DB_DIR/checkins-queued.db" "INSERT INTO queued (queued_at, filepath, attempts) VALUES ($QUEUED_AT_EPOCH, '$FILEPATH_ORIG', 0);";)
			sqlite3 "$DB_DIR/checkins-queued.db" "INSERT INTO queued (queued_at, filepath, attempts) VALUES ($QUEUED_AT_EPOCH, '$FILEPATH_ORIG', 0);" &

			echo " - Added to Checkin queue..."

			# VERIFY_QUEUE_ENTRY=$(sqlite3 -init <(echo .timeout 1000) "$DB_DIR/checkins-queued.db" "SELECT queued_at FROM queued WHERE filepath='$FILEPATH_ORIG';";)
			# if [ "$VERIFY_QUEUE_ENTRY" = "$QUEUED_AT_EPOCH" ]; then 
			# 	echo " - ...and verified."
			# else
			# 	echo " - ...though it could not be verified."
			# fi

		else

			echo " - ...could not be found on the filesystem and was NOT added to queue..."
		
		fi

	else
		echo " - ...was NOT queued because database '$DB_DIR/checkins-queued.db' could not be found"
	fi
fi

# echo " - "
