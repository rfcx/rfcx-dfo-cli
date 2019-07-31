#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

AUDIO_DIRECTORY=$1
if [ -z "$1" ]; then
	if [ -f "$PRIVATE_DIR/prefs_audio_directory" ]; then
		AUDIO_DIRECTORY=`cat "$PRIVATE_DIR/prefs_audio_directory";`;
	fi
fi

AUDIO_FILETYPE=$2
if [ -z "$2" ]; then
	if [ -f "$PRIVATE_DIR/prefs_audio_filetype" ]; then
		AUDIO_FILETYPE=`cat "$PRIVATE_DIR/prefs_audio_filetype";`;
	fi
fi

if [ -d "$AUDIO_DIRECTORY" ]; then 
	
	REGEX_FILTER=".*\.$AUDIO_FILETYPE$"

	for i in {1..12}
	do

		inotifywait --event moved_to --format "%w%f" --timeout 20 --quiet "$AUDIO_DIRECTORY" | grep --line-buffered $REGEX_FILTER | $APP_DIR/utils/stdin.sh "queue"

	done

else

	echo " - "
	echo " - Directory '$AUDIO_DIRECTORY' could not be found..."
	echo " - ."

fi

