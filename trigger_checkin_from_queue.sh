#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

ROW_LIMIT=3;

echo " - "

if [ -f "$DB_DIR/queue-queued.db" ]; then
	if [ -f "$DB_DIR/queue-sent.db" ]; then
	
		QUEUE_ENTRY_COUNT=$(($(sqlite3 "$DB_DIR/queue-queued.db" "SELECT COUNT(*) FROM queued;";)+0))
		
		QUEUE_ENTRIES=$(sqlite3 "$DB_DIR/queue-queued.db" "SELECT filepath FROM queued ORDER BY queued_at ASC LIMIT $ROW_LIMIT;";)
	
		# echo "$QUEUE_ENTRY_COUNT"
		IFS=$'\n'

		CURRENT_ENTRY_ROW=0;

		for QUEUE_ENTRY in $QUEUE_ENTRIES
		do
			CURRENT_ENTRY_ROW=$((CURRENT_ENTRY_ROW+1))

			if [ -f "$QUEUE_ENTRY" ]; then

		  	echo " - $CURRENT_ENTRY_ROW) $SCRIPT_DIR/checkin.sh $QUEUE_ENTRY"

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
	echo " - Database '$DB_DIR/queue-sent.db' could not be found"
	fi		
else
	echo " - Database '$DB_DIR/queue-queued.db' could not be found"
fi

echo " - "

