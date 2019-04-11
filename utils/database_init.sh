#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

TABLE_NAME=$1

QUERY_CREATE="";

if [ "$TABLE_NAME" = "checkins-queued" ]; then 
	QUERY_CREATE="CREATE TABLE queued(queued_at INTEGER, filepath TEXT UNIQUE, attempts INTEGER)";
fi

if [ "$TABLE_NAME" = "checkins-sent" ]; then 
	QUERY_CREATE="CREATE TABLE sent(sent_at INTEGER, filename TEXT)";
fi

if [ "$TABLE_NAME" = "checkins-complete" ]; then 
	QUERY_CREATE="CREATE TABLE complete(sent_at INTEGER, completed_at INTEGER, filename TEXT, audio_id TEXT, checkin_id TEXT, latency INTEGER)";
fi

if [ ! -f "$DB_DIR/$TABLE_NAME.db" ]; then 
	DB_INIT=$(sqlite3 "$DB_DIR/$TABLE_NAME.db" "$QUERY_CREATE";);
	echo " - Created $DB_DIR/$TABLE_NAME.db database.";
else
	echo " - Database '$TABLE_NAME' already exists";
fi
chmod a+rw "$DB_DIR/$TABLE_NAME.db";
