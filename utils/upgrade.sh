#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;

# let's replace this with some dynamic logic below, based on parsing the incoming file paths
UTILS_DIR="$SCRIPT_DIR/utils"; if [ ! -d $UTILS_DIR ]; then mkdir -p $UTILS_DIR; fi;
UTILS_CHECKIN_DIR="$UTILS_DIR/checkin"; if [ ! -d $UTILS_CHECKIN_DIR ]; then mkdir -p $UTILS_CHECKIN_DIR; fi;

# This script checks GitHub for new script versions and upgrades them

SCRIPT_NAME=$1

DOWNLOAD=$(wget -q -O "$TMP_DIR/_$SCRIPT_NAME.sh" "https://raw.githubusercontent.com/rfcx/rfcx-guardian-cli/master/${SCRIPT_NAME//-//}.sh");
chmod a+x "$TMP_DIR/_$SCRIPT_NAME.sh";

NEW_DIGEST=$(openssl dgst -sha1 "$TMP_DIR/_$SCRIPT_NAME.sh" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

SCRIPT_FILEPATH="$SCRIPT_DIR/${SCRIPT_NAME//-//}.sh"

SCRIPT_DIR=$(dirname "$SCRIPT_FILEPATH")
if [ ! -d $SCRIPT_DIR ]; then mkdir -p $SCRIPT_DIR; fi;

OLD_DIGEST="_"
if [ -f "$SCRIPT_FILEPATH" ]; then
	OLD_DIGEST=$(openssl dgst -sha1 "$SCRIPT_FILEPATH" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)
fi

if [ "$NEW_DIGEST" = "$OLD_DIGEST" ]; then 
	# echo " - '$SCRIPT_NAME.sh' - No changes"
	if [ -f "$TMP_DIR/_$SCRIPT_NAME.sh" ]; then rm "$TMP_DIR/_$SCRIPT_NAME.sh"; fi
else

	if [ -f "$TMP_DIR/_$SCRIPT_NAME_old.sh" ]; then rm "$TMP_DIR/_$SCRIPT_NAME_old.sh"; fi
	if [ -f "$SCRIPT_FILEPATH" ]; then mv "$SCRIPT_FILEPATH" "$TMP_DIR/_$SCRIPT_NAME_old.sh"; fi
	if [ -f "$TMP_DIR/_$SCRIPT_NAME.sh" ]; then mv "$TMP_DIR/_$SCRIPT_NAME.sh" "$SCRIPT_FILEPATH"; fi

	echo " - '$SCRIPT_NAME.sh' - UPDATED"
fi
