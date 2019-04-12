#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;


if [ -f "$PRIVATE_DIR/api_hostname" ]; then 

	GUARDIAN_GUID=`cat "$PRIVATE_DIR/guardian_guid";`;
	API_TOKEN=`cat "$PRIVATE_DIR/api_token";`;
	API_HOSTNAME=`cat "$PRIVATE_DIR/api_hostname";`;

	echo " - ";
	echo " - Sending Update CheckIn to $API_HOSTNAME..."
	curl -s -o /dev/null -X GET "$API_HOSTNAME/v1/guardians/$GUARDIAN_GUID/software/all?role=updater-cli&version=0.1.0&battery=100&timestamp=$NOW" -H "Cache-Control: no-cache" -H "x-auth-user: guardian/$GUARDIAN_GUID" -H "x-auth-token: $API_TOKEN";	

fi


