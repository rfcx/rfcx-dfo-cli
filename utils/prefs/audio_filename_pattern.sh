#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

AUDIO_FILENAME_PATTERN="[not set]";
if [ -f "$PRIVATE_DIR/prefs_audio_filename_pattern" ]; then
	AUDIO_FILENAME_PATTERN=`cat "$PRIVATE_DIR/prefs_audio_filename_pattern";`;
fi

echo " - "
echo " - Incoming Audio Filename Pattern (for Date-Time parsing) is currently set to: '$AUDIO_FILENAME_PATTERN'";
read -p " - Would you like to [re]set the expected incoming audio filename pattern? (y/n): " -n 1 -r
FORCE_SET_AUDIO_FILENAME_PATTERN="${REPLY}";
echo ""

if [ "$FORCE_SET_AUDIO_FILENAME_PATTERN" = "y" ]; then
	
		RESET_AUDIO_FILENAME_PATTERN=$(rm -rf $PRIVATE_DIR/prefs_audio_filename_pattern)

		echo " - "
		echo " - Please provide the expected incoming audio filename pattern (Example: 'SCW1840_%Y%Y%m%d_%H%M%S'):"
		read -p " - Enter the audio filename pattern: " -n 80 -r
		AUDIO_FILENAME_PATTERN="${REPLY}"

fi

echo " - "

if [ "$AUDIO_FILENAME_PATTERN" = "[not set]" ]; then
	RESET_AUDIO_FILENAME_PATTERN=$(rm -rf $PRIVATE_DIR/prefs_audio_filename_pattern)
	echo " - Error: Audio Filename Pattern was not set. This is required."
else
	echo "$AUDIO_FILENAME_PATTERN" > "$PRIVATE_DIR/prefs_audio_filename_pattern"
	echo " - Incoming Audio Filename Pattern set to: '$AUDIO_FILENAME_PATTERN'"
fi
