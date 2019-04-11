#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;

echo " - "

FILENAME_TIMESTAMP_FORMAT=$1

MAX_BATCH_COUNT=3

if [ -f "$DB_DIR/checkins-queued.db" ]; then
	if [ -f "$DB_DIR/checkins-sent.db" ]; then
	
		for i in {1..60}
		do

			QUEUE_ENTRY_COUNT=$(($(sqlite3 "$DB_DIR/checkins-queued.db" "SELECT COUNT(*) FROM queued;";)+0))
			
			if [ "$QUEUE_ENTRY_COUNT" -gt "0" ]; then

				echo " - $QUEUE_ENTRY_COUNT item(s) currently in the queue."

				# Only MAX_BATCH_COUNT checkins will be processed at a time...
				if [ "$QUEUE_ENTRY_COUNT" -gt "$MAX_BATCH_COUNT" ]; then QUEUE_ENTRY_COUNT=$MAX_BATCH_COUNT; fi

				QUEUE_ENTRIES=$(sqlite3 "$DB_DIR/checkins-queued.db" "SELECT filepath FROM queued ORDER BY queued_at ASC LIMIT $QUEUE_ENTRY_COUNT;";)
			
				echo " - $QUEUE_ENTRY_COUNT item(s) will be processed..."

				IFS=$'\n'

				for QUEUE_ENTRY in $QUEUE_ENTRIES
				do

					if [ -f "$QUEUE_ENTRY" ]; then

						REMOVE_FROM_QUEUED=$(sqlite3 "$DB_DIR/checkins-queued.db" "DELETE FROM queued WHERE filepath='$QUEUE_ENTRY';";)
						QUEUE_ENTRY_FILENAME=$(basename -- "$QUEUE_ENTRY")
						SENT_AT_EPOCH=$(($($GNU_DATE_BIN '+%s')*1000))
						ADD_TO_SENT=$(sqlite3 "$DB_DIR/checkins-sent.db" "INSERT INTO sent (sent_at, filename) VALUES ($SENT_AT_EPOCH, '$QUEUE_ENTRY_FILENAME');";)

				  	$SCRIPT_DIR/checkin.sh "$QUEUE_ENTRY" "$FILENAME_TIMESTAMP_FORMAT"

				  else

				  	echo " - '$QUEUE_ENTRY' could not be found on filesystem..."

				  fi
				done

			else
				echo " - Queue is currently empty."
			fi

			sleep 2

		done

	else
	echo " - Database '$DB_DIR/checkins-sent.db' could not be found"
	fi		
else
	echo " - Database '$DB_DIR/checkins-queued.db' could not be found"
fi

echo " - "

