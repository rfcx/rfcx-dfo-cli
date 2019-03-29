#!/bin/bash

AUDIO_FORMAT="wav"
DATETIME_FILENAME_FORMAT="%Y%m%d_%H%M%S.$AUDIO_FORMAT"

AUDIO_DIR=$1;

for AUDIO_FILEPATH in $AUDIO_DIR/*.$AUDIO_FORMAT; do

	AUDIO_FILENAME=$(basename -- "$AUDIO_FILEPATH")
	read -r DATETIME_ISO DATETIME_EPOCH <<< "$(date -jf "$DATETIME_FILENAME_FORMAT" '+%Y-%m-%dT%H:%M:%S.000%z %s' "$AUDIO_FILENAME")"

 	for var in DATETIME_ISO DATETIME_EPOCH; do echo "$var=${!var}"; done

done

