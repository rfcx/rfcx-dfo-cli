#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$SCRIPT_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;

# This script checks GitHub for new script versions and upgrades them

SCRIPT_NAME=$1

DOWNLOAD=$(wget -q -O "$TMP_DIR/_$SCRIPT_NAME.sh" "https://raw.githubusercontent.com/rfcx/rfcx-guardian-cli/master/$SCRIPT_NAME.sh");
chmod a+x "$TMP_DIR/_$SCRIPT_NAME.sh";

NEW_DIGEST=$(openssl dgst -sha1 "$TMP_DIR/_$SCRIPT_NAME.sh" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

OLD_DIGEST="_"
if [ -f "$SCRIPT_DIR/$SCRIPT_NAME.sh"]; then
	OLD_DIGEST=$(openssl dgst -sha1 "$SCRIPT_DIR/$SCRIPT_NAME.sh" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)
fi

if [ "$NEW_DIGEST" = "$OLD_DIGEST" ]; then 
	echo " - '$SCRIPT_NAME.sh' script has not changed... no update will be performed..."
	if [ -f "$TMP_DIR/_$SCRIPT_NAME.sh" ]; then rm "$TMP_DIR/_$SCRIPT_NAME.sh"; fi
else

	if [ -f "$TMP_DIR/_$SCRIPT_NAME_old.sh" ]; then rm "$TMP_DIR/_$SCRIPT_NAME_old.sh"; fi
	if [ -f "$SCRIPT_DIR/$SCRIPT_NAME.sh" ]; then mv "$SCRIPT_DIR/$SCRIPT_NAME.sh" "$TMP_DIR/_$SCRIPT_NAME_old.sh"; fi
	if [ -f "$TMP_DIR/_$SCRIPT_NAME.sh" ]; then mv "$TMP_DIR/_$SCRIPT_NAME.sh" "$SCRIPT_DIR/$SCRIPT_NAME.sh"; fi

	echo " - '$SCRIPT_NAME.sh' script has been updated to latest version..."
fi
