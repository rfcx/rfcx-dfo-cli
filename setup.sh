#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
PRIVATE_DIR="$SCRIPT_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

if [ ! -f "$PRIVATE_DIR/guid" ]; then 

	CHAR_OPTIONS=abcdef0123456789
	GUID=`for i in {1..12} ; do echo -n "${CHAR_OPTIONS:RANDOM%${#CHAR_OPTIONS}:1}"; done;`
	CHAR_OPTIONS=abcdefghijklmnopqrstuvwxyz0123456789
	TOKEN=`for i in {1..40} ; do echo -n "${CHAR_OPTIONS:RANDOM%${#CHAR_OPTIONS}:1}"; done;`

	echo "$GUID" > "$PRIVATE_DIR/guid"
	echo "$TOKEN" > "$PRIVATE_DIR/token"

	HOSTNAME="https://api.rfcx.org"
	echo "$HOSTNAME" > "$PRIVATE_DIR/hostname"

else

	GUID=`cat "$PRIVATE_DIR/guid";`;
	TOKEN=`cat "$PRIVATE_DIR/token";`;
	HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;

fi

read -p "Please provide a 8 digit registration token: " -n 8 -r
REGISTRATION_TOKEN="${REPLY}";

curl -X POST "$HOSTNAME/v1/guardians/register" -H "Content-Type: application/x-www-form-urlencoded" -H "cache-control: no-cache" -H "x-auth-user: register" -H "x-auth-token: $REGISTRATION_TOKEN" -d "guid=$GUID&token=$TOKEN"


wget -q -O "$SCRIPT_DIR/update.sh" https://raw.githubusercontent.com/rfcx/rfcx-dfo-cli/master/update.sh
chmod a+x "$SCRIPT_DIR/update.sh";