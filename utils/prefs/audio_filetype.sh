#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

AUDIO_FILETYPE="wav";
if [ -f "$PRIVATE_DIR/prefs_audio_filetype" ]; then
	AUDIO_FILETYPE=`cat "$PRIVATE_DIR/prefs_audio_filetype";`;
fi

echo " - "
echo " - Incoming Audio Filetype is currently set to: '$AUDIO_FILETYPE'";
read -p " - Would you like to [re]set the expected incoming audio filetype? (y/n): " -n 1 -r
FORCE_SET_AUDIO_FILETYPE="${REPLY}";
echo ""

if [ "$FORCE_SET_AUDIO_FILETYPE" = "y" ]; then
	
		RESET_AUDIO_FILETYPE=$(rm -rf $PRIVATE_DIR/prefs_audio_filetype)

		echo " - "
		echo " - Please provide the expected incoming audio filetype (Examples: 'wav', 'flac', 'opus', 'mp3'):"
		read -p " - Enter the audio filetype: " -n 15 -r
		AUDIO_FILETYPE=$(echo ${REPLY} | tr '[:upper:]' '[:lower:]')
		echo "$AUDIO_FILETYPE" > "$PRIVATE_DIR/prefs_audio_filetype"

fi

if [ ! -f "$PRIVATE_DIR/prefs_audio_filetype" ]; then
	echo "$AUDIO_FILETYPE" > "$PRIVATE_DIR/prefs_audio_filetype"
fi

echo " - "
echo " - Incoming Audio Filetype set to: $AUDIO_FILETYPE"
