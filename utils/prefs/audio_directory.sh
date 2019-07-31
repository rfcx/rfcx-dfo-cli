#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

AUDIO_DIRECTORY="[not set]";
if [ -f "$PRIVATE_DIR/prefs_audio_directory" ]; then
	AUDIO_DIRECTORY=`cat "$PRIVATE_DIR/prefs_audio_directory";`;
fi

echo " - "
echo " - Incoming Audio Directory is currently set to: $AUDIO_DIRECTORY";
read -p " - Would you like to [re]set the incoming audio directory path? (y/n): " -n 1 -r
FORCE_SET_AUDIO_DIRECTORY="${REPLY}";
echo ""

if [ "$FORCE_SET_AUDIO_DIRECTORY" = "y" ]; then
	
		RESET_AUDIO_DIRECTORY=$(rm -rf $PRIVATE_DIR/prefs_audio_directory)

		echo " - "
		echo " - Please provide the expected incoming audio directory filepath (Example: '/var/www/sites/Sand_Heads/'):"
		read -p " - Enter the audio directory filepath: " -n 120 -r
		AUDIO_DIRECTORY="${REPLY}"

fi

echo " - "

if [ -d "$AUDIO_DIRECTORY" ]; then 
	echo "$AUDIO_DIRECTORY" > "$PRIVATE_DIR/prefs_audio_directory"
	echo " - Incoming Audio Directory set to: $AUDIO_DIRECTORY"
else
	RESET_AUDIO_DIRECTORY=$(rm -rf $PRIVATE_DIR/prefs_audio_directory)
	echo " - Error: Directory Path '$AUDIO_DIRECTORY' could not be found..."
fi

