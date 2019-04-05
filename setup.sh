#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
PRIVATE_DIR="$SCRIPT_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

echo " - Setup Launched"
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

	echo "$REGISTER" > "$PRIVATE_DIR/registered"

fi



# Download 'upgrade' script
if [ ! -f "$SCRIPT_DIR/upgrade.sh" ]; then
	DOWNLOAD=$(wget -q -O "$SCRIPT_DIR/upgrade.sh" "https://raw.githubusercontent.com/rfcx/rfcx-guardian-cli/master/upgrade.sh");
	chmod a+x "$SCRIPT_DIR/upgrade.sh";
fi

# use 'upgrade' script to fetch 'update' script
$SCRIPT_DIR/upgrade.sh "update"

# run 'update' script
$SCRIPT_DIR/update.sh

echo " - Setup complete"
echo " - "



