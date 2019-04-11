#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;

echo " - "

if [ -f "$DB_DIR/queue-queued.db" ]; then
	if [ -f "$DB_DIR/queue-sent.db" ]; then
	
		QUEUE_ENTRY_COUNT=$(($(sqlite3 "$DB_DIR/queue-queued.db" "SELECT COUNT(*) FROM queued;";)+0))
		
		if [ "$QUEUE_ENTRY_COUNT" -gt "0" ]; then

			echo " - There are currently $QUEUE_ENTRY_COUNT items in the queue."

			# Only three checkins will be processed at a time...
			if [ "$QUEUE_ENTRY_COUNT" -gt "3" ]; then QUEUE_ENTRY_COUNT=3; fi

			QUEUE_ENTRIES=$(sqlite3 "$DB_DIR/queue-queued.db" "SELECT filepath FROM queued ORDER BY queued_at ASC LIMIT $QUEUE_ENTRY_COUNT;";)
		
			echo " - $QUEUE_ENTRY_COUNT items will be processed..."

			IFS=$'\n'

			for QUEUE_ENTRY in $QUEUE_ENTRIES
			do

				if [ -f "$QUEUE_ENTRY" ]; then

					REMOVE_FROM_QUEUED=$(sqlite3 "$DB_DIR/queue-queued.db" "DELETE FROM queued WHERE filepath='$QUEUE_ENTRY';";)
					QUEUE_ENTRY_FILENAME=$(basename -- "$QUEUE_ENTRY")
					SENT_AT_EPOCH=$(($($GNU_DATE_BIN '+%s')*1000))
					ADD_TO_SENT=$(sqlite3 "$DB_DIR/queue-sent.db" "INSERT INTO sent (sent_at, filename) VALUES ($SENT_AT_EPOCH, '$QUEUE_ENTRY_FILENAME');";)

			  	$SCRIPT_DIR/checkin.sh "$QUEUE_ENTRY"

			  else

			  	echo " - '$QUEUE_ENTRY' could not be found on filesystem..."

			  fi
			done

			# while read -r QUEUE_ENTRY; do
			  
			#   if [ -f "$QUEUE_ENTRY" ]; then

			#   	$SCRIPT_DIR/checkin.sh "$QUEUE_ENTRY"

			#   else

			#   	echo " - '$QUEUE_ENTRY' could not be found..."

			#   fi

			# done <<< "$QUEUE_ENTRIES"
		else
			echo " - Queue is currently empty."
		fi
	else
	echo " - Database '$DB_DIR/queue-sent.db' could not be found"
	fi		
else
	echo " - Database '$DB_DIR/queue-queued.db' could not be found"
fi

echo " - "

