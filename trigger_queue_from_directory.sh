#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

TARGET_DIRECTORY=$1
TARGET_FILETYPE=$2

if [ -d "$TARGET_DIRECTORY" ]; then 
	
	REGEX_FILTER=".*\.$TARGET_FILETYPE$"

	# THIS NEED TO BE OVERHAULED...

	for FILEPATH_ORIG in $TARGET_DIRECTORY/*.$TARGET_FILETYPE; do

		# $APP_DIR/queue.sh $ORIG_FILE


		# echo $FILEPATH_ORIG
		FILENAME_ORIG=$(basename -- "$FILEPATH_ORIG")
		CODEC_ORIG=$(echo $FILENAME_ORIG | rev | cut -d'.' -f 1 | rev | tr '[:upper:]' '[:lower:]')
		TIMESTAMP_ORIG=$(echo $FILENAME_ORIG | cut -d'.' -f 1)
		EPOCH=$(($((16#$TIMESTAMP_ORIG))*1000))
		echo "$TIMESTAMP_ORIG - $EPOCH"
		EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$FILEPATH_ORIG" -ar 48000 "$TARGET_DIRECTORY/-flac/$EPOCH.flac")


	done

else

	echo " - "
	echo " - Directory '$TARGET_DIRECTORY' could not be found..."
	echo " - ."

fi

