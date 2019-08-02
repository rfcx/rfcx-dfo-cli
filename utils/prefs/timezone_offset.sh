#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

TIMEZONE_OFFSET="+0000";
if [ -f "$PRIVATE_DIR/prefs_timezone_offset" ]; then
	TIMEZONE_OFFSET=`cat "$PRIVATE_DIR/prefs_timezone_offset";`;
fi

echo " - "
echo " - System Timezone Offset set to: '$TIMEZONE_OFFSET'";
read -p " - Would you like to [re]set the System Timezone Offset? (y/n): " -n 1 -r
FORCE_SET_TIMEZONE_OFFSET="${REPLY}";
echo ""

if [ "$FORCE_SET_TIMEZONE_OFFSET" = "y" ]; then
	
		RESET_TIMEZONE_OFFSET=$(rm -rf $PRIVATE_DIR/prefs_timezone_offset)

		echo " - "
		echo " - Please provide the System Timezone Offset (Examples: '+0000', '-0700', '+0430'):"
		read -p " - Enter the System Timezone Offset: " -n 15 -r
		TIMEZONE_OFFSET=$(echo ${REPLY} | tr '[:upper:]' '[:lower:]')

fi

if [ ! -f "$PRIVATE_DIR/prefs_timezone_offset" ]; then
	TIMEZONE_OFFSET=$(echo -e "${TIMEZONE_OFFSET}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
	echo "$TIMEZONE_OFFSET" > "$PRIVATE_DIR/prefs_timezone_offset"
fi

echo " - "
echo " - System Timezone Offset set to: $TIMEZONE_OFFSET"
