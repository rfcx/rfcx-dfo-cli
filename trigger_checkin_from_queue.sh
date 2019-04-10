#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;


if [ -f "$DB_DIR/queue-queued.db" ]; then

	QUEUE_ENTRIES=$(sqlite3 "$DB_DIR/queue-queued.db" "SELECT filepath FROM queued ORDER BY queued_at ASC;";)
	
	while read -r QUEUE_ENTRY; do
	  echo "... $line ..."
	done <<< "$QUEUE_ENTRIES"

else



fi

