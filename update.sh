#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
PRIVATE_DIR="$SCRIPT_DIR/.private"

GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;

echo " - ";

if [ ! -d "$SCRIPT_DIR/.git" ]; then 

	echo " - Checking GitHub for newer 'checkin.sh' script...";

	EXEC_DOWNLOAD=`wget -q -O "$TMP_DIR/_checkin.sh" https://raw.githubusercontent.com/rfcx/rfcx-guardian-cli/master/checkin.sh`;

	chmod a+x "$TMP_DIR/_checkin.sh";

	NEW_CHECKIN_SCR_DIGEST=$(openssl dgst -sha1 "$TMP_DIR/_checkin.sh" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)
	OLD_CHECKIN_SCR_DIGEST=$(openssl dgst -sha1 "$SCRIPT_DIR/checkin.sh" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

	if [ "$NEW_CHECKIN_SCR_DIGEST" = "$OLD_CHECKIN_SCR_DIGEST" ]; then 
		echo " - 'checkin.sh' script has not changed... no update will be performed..."
		if [ -f "$TMP_DIR/_checkin.sh" ]; then rm "$TMP_DIR/_checkin.sh"; fi
	else

		if [ -f "$TMP_DIR/_checkin_old.sh" ]; then rm "$TMP_DIR/_checkin_old.sh"; fi
		if [ -f "$SCRIPT_DIR/checkin.sh" ]; then mv "$SCRIPT_DIR/checkin.sh" "$TMP_DIR/_checkin_old.sh"; fi
		if [ -f "$TMP_DIR/_checkin.sh" ]; then mv "$TMP_DIR/_checkin.sh" "$SCRIPT_DIR/checkin.sh"; fi

		echo " - 'checkin.sh' script has been updated to latest version..."
	fi

else

	echo " - Blocking update process because this is a Git repository.";

fi

GUID=`cat "$PRIVATE_DIR/guid";`;
TOKEN=`cat "$PRIVATE_DIR/token";`;
NOW=$(($($GNU_DATE_BIN '+%s')*1000))

if [ -f "$PRIVATE_DIR/hostname" ]; then 
	echo " - Sending 'ping' to RFCx API..."
	HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;
	curl -s -o /dev/null -X GET "$HOSTNAME/v1/guardians/$GUID/software/all?role=updater&version=0.4.0&battery=100&timestamp=$NOW" -H "cache-control: no-cache" -H "x-auth-user: guardian/$GUID" -H "x-auth-token: $TOKEN";	
fi

