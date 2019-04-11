#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
LOGS_DIR="$SCRIPT_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;
DB_DIR="$SCRIPT_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;
UTILS_DIR="$SCRIPT_DIR/utils"; if [ ! -d $UTILS_DIR ]; then mkdir -p $UTILS_DIR; fi;
PRIVATE_DIR="$SCRIPT_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

echo " - "
echo " - Setup: Launched"
echo " - "

if [ ! -f "$PRIVATE_DIR/guid" ]; then 

	echo " - Script is running for the first time..."
	echo " - Generating new Guardian guid and token."
	echo " - "

	CHAR_OPTIONS=abcdef0123456789
	GUID=`for i in {1..12} ; do echo -n "${CHAR_OPTIONS:RANDOM%${#CHAR_OPTIONS}:1}"; done;`

	CHAR_OPTIONS=abcdefghijklmnopqrstuvwxyz0123456789
	TOKEN=`for i in {1..40} ; do echo -n "${CHAR_OPTIONS:RANDOM%${#CHAR_OPTIONS}:1}"; done;`

	echo "$GUID" > "$PRIVATE_DIR/guid"
	echo "$TOKEN" > "$PRIVATE_DIR/token"

	HOSTNAME="https://api.rfcx.org"
	echo "$HOSTNAME" > "$PRIVATE_DIR/hostname"

	echo " - Guardian: $GUID"
	echo " - Token: [secret]"
	echo " - RFCx API: $HOSTNAME"
	echo " - "

else

	GUID=`cat "$PRIVATE_DIR/guid";`;
	TOKEN=`cat "$PRIVATE_DIR/token";`;
	HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;

	echo " - This Guardian has previously been setup"
	echo " - "
	echo " - Guardian: $GUID"
	echo " - Token: [secret]"
	echo " - RFCx API: $HOSTNAME"
	echo " - "

fi




if [ ! -f "$PRIVATE_DIR/registered" ]; then 

	echo " - This Guardian must be registered with the RFCx API (see below)..."
	echo " - "

	read -p " - Please provide a Registration Token (8 digit): " -n 8 -r
	REGISTRATION_TOKEN="${REPLY}";

	REGISTER=$(curl -s -X POST "$HOSTNAME/v1/guardians/register" -H "Content-Type: application/x-www-form-urlencoded" -H "cache-control: no-cache" -H "x-auth-user: register" -H "x-auth-token: $REGISTRATION_TOKEN" -d "guid=$GUID&token=$TOKEN")

	echo ""; echo " - "
	echo " - $REGISTER"

	if [ ! "$REGISTER" = "Unauthorized" ]; then
		
		echo "$REGISTER" > "$PRIVATE_DIR/registered"

	fi

fi

# Download 'upgrade' script
if [ ! -f "$SCRIPT_DIR/utils/upgrade.sh" ]; then
	DOWNLOAD=$(wget -q -O "$SCRIPT_DIR/utils/upgrade.sh" "https://raw.githubusercontent.com/rfcx/rfcx-guardian-cli/master/utils/upgrade.sh");
	chmod a+x "$SCRIPT_DIR/utils/upgrade.sh";
fi

# use 'upgrade' script to fetch 'update' script
$SCRIPT_DIR/utils/upgrade.sh "update" && $SCRIPT_DIR/update.sh

# use 'upgrade' script to fetch 'crontab' script
$SCRIPT_DIR/utils/upgrade.sh "utils-crontab"

# set cron jobs
if [ -f "$SCRIPT_DIR/utils/crontab.sh" ]; then
	$SCRIPT_DIR/utils/crontab.sh "update" 20
fi

# Initialize checkin queue database files
if [ ! -f "$DB_DIR/queue-queued.db" ]; then QUEUED_INIT=$(sqlite3 "$DB_DIR/queue-queued.db" "CREATE TABLE queued(queued_at INTEGER, filepath TEXT, attempts INTEGER)";); fi
if [ ! -f "$DB_DIR/queue-sent.db" ]; then SENT_INIT=$(sqlite3 "$DB_DIR/queue-sent.db" "CREATE TABLE sent(sent_at INTEGER, filename TEXT)";); fi
if [ ! -f "$DB_DIR/queue-complete.db" ]; then COMPLETE_INIT=$(sqlite3 "$DB_DIR/queue-complete.db" "CREATE TABLE complete(sent_at INTEGER, completed_at INTEGER, filename TEXT, audio_id TEXT, checkin_id TEXT, latency INTEGER)";); fi
chmod a+rw "$DB_DIR/queue-queued.db" "$DB_DIR/queue-sent.db" "$DB_DIR/queue-complete.db";


echo " - "
echo " - Setup: Complete"
echo " - "
