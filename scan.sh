#!/bin/bash

# requires soxi, ffmpeg, openssl, curl

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

AUDIO_FORMAT="wav"
DATETIME_FILENAME_FORMAT="%Y%m%d_%H%M%S.$AUDIO_FORMAT"

WORKING_DIR="/tmp/rfcx-dfo"
if [ ! -d $WORKING_DIR ]; then mkdir -p $WORKING_DIR; fi

AUDIO_DIR=$1;
GUARDIAN_GUID="c9d541166e12"

for AUDIO_ORIG_FILEPATH in $AUDIO_DIR/*.$AUDIO_FORMAT; do

	AUDIO_ORIG_FILENAME=$(basename -- "$AUDIO_ORIG_FILEPATH")
	read -r DATETIME_ISO DATETIME_EPOCH_ <<< "$(date -jf "$DATETIME_FILENAME_FORMAT" '+%Y-%m-%dT%H:%M:%S.000%z %s' "$AUDIO_ORIG_FILENAME")"

	DATETIME_EPOCH=$((DATETIME_EPOCH_*1000))
	AUDIO_FLAC_FILEPATH="$WORKING_DIR/$DATETIME_EPOCH.flac"

	if [ ! -f "$AUDIO_FLAC_FILEPATH.gz" ]; then

		AUDIO_SAMPLE_RATE=$(soxi -r "$AUDIO_ORIG_FILEPATH")
		AUDIO_SAMPLE_COUNT=$(soxi -s "$AUDIO_ORIG_FILEPATH")
		EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$AUDIO_ORIG_FILEPATH" -ar "$AUDIO_SAMPLE_RATE" "$AUDIO_FLAC_FILEPATH")
		AUDIO_FLAC_SHA1=$(openssl dgst -sha1 "$AUDIO_FLAC_FILEPATH" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

		CUT_FLAG=5; if [[ "$OSTYPE" == "darwin"* ]]; then CUT_FLAG=8; fi;  # -f 8 for OSX, -f 5 for linux
		AUDIO_FLAC_FILESIZE=$(ls -l "$AUDIO_FLAC_FILEPATH" | cut -d' ' -f $CUT_FLAG)

		echo "$AUDIO_ORIG_FILENAME - $AUDIO_SAMPLE_RATE - $AUDIO_SAMPLE_COUNT - $AUDIO_FLAC_SHA1 - $AUDIO_FLAC_FILESIZE"

		EXEC_AUDIO_COMPRESS=$(gzip -q "$AUDIO_FLAC_FILEPATH")

		CHECKIN_JSON="{}"
		CHECKIN_JSON_ZIPPED=$(echo "$CHECKIN_JSON" | gzip -cf)
		echo $CHECKIN_JSON_ZIPPED;

	fi


done

