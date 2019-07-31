#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

AUDIO_DIRECTORY=$1
#if [ -z "$1" ]; then
if [ "$1" == "" ]; then
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

			# # THIS NEED TO BE OVERHAULED...

	# for FILEPATH_ORIG in $AUDIO_DIRECTORY/*.$AUDIO_FILETYPE; do
	for FILEPATH_ORIG in $AUDIO_DIRECTORY/*; do

			# 	# $APP_DIR/queue.sh $ORIG_FILE


			FILENAME_ORIG=$(basename -- "$FILEPATH_ORIG")


			echo $FILENAME_ORIG
			$APP_DIR/queue.sh $FILEPATH_ORIG

			# 	# CODEC_ORIG=$(echo $FILENAME_ORIG | rev | cut -d'.' -f 1 | rev | tr '[:upper:]' '[:lower:]')
			# 	# TIMESTAMP_ORIG=$(echo $FILENAME_ORIG | cut -d'.' -f 1)
			# 	# EPOCH=$(($((16#$TIMESTAMP_ORIG))*1000))
			# 	# echo "$TIMESTAMP_ORIG - $EPOCH"
			# 	# EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$FILEPATH_ORIG" -ar 48000 "$AUDIO_DIRECTORY/-flac/$EPOCH.flac")


	done

else

	echo " - "
	echo " - Directory '$AUDIO_DIRECTORY' could not be found..."
	echo " - ."

fi

