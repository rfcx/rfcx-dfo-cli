#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;


if [ ! -f "$PRIVATE_DIR/api_registered" ]; then 

	GUARDIAN_GUID=`cat "$PRIVATE_DIR/guardian_guid";`;
	API_TOKEN=`cat "$PRIVATE_DIR/api_token";`;
	API_HOSTNAME=`cat "$PRIVATE_DIR/api_hostname";`;

	echo " - "
	echo " - This Guardian must be registered with the RFCx API (see below)..."
	echo " - "
	read -p " - Please provide a Registration Token (8 digit): " -n 8 -r
	REGISTRATION_TOKEN="${REPLY}";
	EXEC_REGISTER=$(curl -s -X POST "$API_HOSTNAME/v1/guardians/register" -H "Content-Type: application/x-www-form-urlencoded" -H "cache-control: no-cache" -H "x-auth-user: register" -H "x-auth-token: $REGISTRATION_TOKEN" -d "guid=$GUARDIAN_GUID&token=$API_TOKEN")
	echo ""; echo " - "
	echo " - $EXEC_REGISTER"
	if [ ! "$EXEC_REGISTER" = "Unauthorized" ]; then
		echo "$EXEC_REGISTER" > "$PRIVATE_DIR/api_registered"
	fi

else

	echo " - "
	echo " - This Guardian has already been registered with the API"

fi

