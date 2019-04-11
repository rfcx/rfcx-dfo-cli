#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";
DB_DIR="$APP_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;

TABLE_NAME=$1

TABLE_CREATE_QUERY="";

if [ "$TABLE_NAME" = "checkins-queued" ]; then 
	TABLE_CREATE_QUERY="CREATE TABLE queued(queued_at INTEGER, filepath TEXT UNIQUE, attempts INTEGER)";
fi

if [ "$TABLE_NAME" = "checkins-sent" ]; then 
	TABLE_CREATE_QUERY="CREATE TABLE sent(sent_at INTEGER, filename TEXT)";
fi

if [ "$TABLE_NAME" = "checkins-complete" ]; then 
	TABLE_CREATE_QUERY="CREATE TABLE complete(sent_at INTEGER, completed_at INTEGER, filename TEXT, audio_id TEXT, checkin_id TEXT, latency INTEGER)";
fi

if [ ! -f "$DB_DIR/$TABLE_NAME.db" ]; then 
	DB_INIT=$(sqlite3 "$DB_DIR/$TABLE_NAME.db" "$TABLE_CREATE_QUERY";);
	echo " - Created $DB_DIR/$TABLE_NAME.db database.";
else
	echo " - Database '$TABLE_NAME' already exists";
fi
chmod a+rw "$DB_DIR/$TABLE_NAME.db";
