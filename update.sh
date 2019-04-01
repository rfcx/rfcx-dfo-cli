#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

TMP_DIR="$SCRIPT_DIR/tmp"
if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi

if [ ! -d "$SCRIPT_DIR/.git" ]; then 

	echo "updating checkin script...";

	EXEC_DOWNLOAD=`wget -q -O "$TMP_DIR/_checkin.sh" https://raw.githubusercontent.com/rfcx/rfcx-dfo-cli/master/checkin.sh`;

	chmod a+x "$TMP_DIR/_checkin.sh";

	NEW_CHECKIN_SCR_DIGEST=$(openssl dgst -sha1 "$TMP_DIR/_checkin.sh" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)
	OLD_CHECKIN_SCR_DIGEST=$(openssl dgst -sha1 "$SCRIPT_DIR/checkin.sh" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

	if [ "$NEW_CHECKIN_SCR_DIGEST" = "$OLD_CHECKIN_SCR_DIGEST" ]; then 
		echo "no need for update — checkin script has not been changed..."
		if [ -f "$TMP_DIR/_checkin.sh" ]; then rm "$TMP_DIR/_checkin.sh"; fi
	else

		if [ -f "$TMP_DIR/_checkin_old.sh" ]; then rm "$TMP_DIR/_checkin_old.sh"; fi
		mv "$SCRIPT_DIR/checkin.sh" "$TMP_DIR/_checkin_old.sh" && mv "$TMP_DIR/_checkin.sh" "$SCRIPT_DIR/checkin.sh";

		echo "update now"
	fi

else

	echo "not updating because this is a git repository";

fi

PRIVATE_DIR="$SCRIPT_DIR/.private"
GUID=`cat "$PRIVATE_DIR/guid";`;
TOKEN=`cat "$PRIVATE_DIR/token";`;

HOSTNAME="api.rfcx.org";
if [ ! -f "$PRIVATE_DIR/hostname" ]; then 
	echo "$HOSTNAME" > "$PRIVATE_DIR/hostname"; 
else
	HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;
fi

NOW=$(($(date +%s)*1000))

curl -s -o /dev/null -X GET "https://$HOSTNAME/v1/guardians/$GUID/software/all?role=updater&version=0.4.0&battery=100&timestamp=$NOW" -H "cache-control: no-cache" -H "x-auth-user: guardian/$GUID" -H "x-auth-token: $TOKEN";


