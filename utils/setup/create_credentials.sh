#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

## Generate and set Guardian Guid
if [ ! -f "$PRIVATE_DIR/guardian_guid" ]; then
	HEX_CHAR_OPTIONS=abcdef0123456789
	GUARDIAN_GUID=`for i in {1..12} ; do echo -n "${HEX_CHAR_OPTIONS:RANDOM%${#HEX_CHAR_OPTIONS}:1}"; done;`
	echo "$GUARDIAN_GUID" > "$PRIVATE_DIR/guardian_guid"
else
	GUARDIAN_GUID=`cat "$PRIVATE_DIR/guardian_guid";`;
fi 

## Generate and set API auth token
if [ ! -f "$PRIVATE_DIR/api_token" ]; then
	FULL_CHAR_OPTIONS=abcdefghijklmnopqrstuvwxyz0123456789
	API_TOKEN=`for i in {1..40} ; do echo -n "${FULL_CHAR_OPTIONS:RANDOM%${#FULL_CHAR_OPTIONS}:1}"; done;`
	echo "$API_TOKEN" > "$PRIVATE_DIR/api_token"
else
	API_TOKEN=`cat "$PRIVATE_DIR/api_token";`;
fi 

## Set API https url hostname
if [ ! -f "$PRIVATE_DIR/api_hostname" ]; then 
	API_HOSTNAME="https://api.rfcx.org"
	echo "$API_HOSTNAME" > "$PRIVATE_DIR/api_hostname"
else
	API_HOSTNAME=`cat "$PRIVATE_DIR/api_hostname";`;
fi

echo " - Guardian: $GUARDIAN_GUID"
echo " - Token: [secret]"
echo " - RFCx API: $API_HOSTNAME"
