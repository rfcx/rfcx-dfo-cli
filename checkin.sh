#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

TMP_DIR="$SCRIPT_DIR/tmp"
if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi

PRIVATE_DIR="$SCRIPT_DIR/.private"

if [ ! -f "$PRIVATE_DIR/guid" ]; then 

	echo "checkin cannot be run because no guid/credentials have been set"

else

	GUARDIAN_GUID=`cat "$PRIVATE_DIR/guid";`;
	GUARDIAN_TOKEN=`cat "$PRIVATE_DIR/token";`;

	read AUDIO_ORIG_FILEPATH
	AUDIO_ORIG_FORMAT=$(echo $AUDIO_ORIG_FILEPATH | rev | cut -d'.' -f 1 | rev)
	DATETIME_FILENAME_FORMAT="%Y%m%d_%H%M%S.$AUDIO_ORIG_FORMAT"
	AUDIO_ORIG_FILENAME=$(basename -- "$AUDIO_ORIG_FILEPATH")
	SENSOR_GUID=$(echo $AUDIO_ORIG_FILENAME | cut -d'_' -f 1)
	FILENAME_DATETIME_OFFSET=$((${#SENSOR_GUID}+1))
	SENSOR_GUID_LENGTH=$((${#SENSOR_GUID}+1))
	FILENAME_DATETIME_LENGTH=$((${#AUDIO_ORIG_FILENAME}-${#SENSOR_GUID}-1))

	read -r DATETIME_ISO DATETIME_EPOCH_ <<< "$(date -jf "$DATETIME_FILENAME_FORMAT" '+%Y-%m-%dT%H:%M:%S.000%z %s' "${AUDIO_ORIG_FILENAME:SENSOR_GUID_LENGTH:FILENAME_DATETIME_LENGTH}")"

	DATETIME_EPOCH=$((DATETIME_EPOCH_*1000))
	AUDIO_FLAC_FILEPATH="$TMP_DIR/$DATETIME_EPOCH.flac"

	# Pre Cleanup
	EXEC_CLEANUP_PRE=$(rm -f "$AUDIO_FLAC_FILEPATH" "$AUDIO_FLAC_FILEPATH.gz")

	AUDIO_SAMPLE_RATE=$(soxi -r "$AUDIO_ORIG_FILEPATH")
	EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$AUDIO_ORIG_FILEPATH" -ar "$AUDIO_SAMPLE_RATE" "$AUDIO_FLAC_FILEPATH")
	AUDIO_FLAC_SHA1=$(openssl dgst -sha1 "$AUDIO_FLAC_FILEPATH" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

	CUT_FLAG=5; if [[ "$OSTYPE" == "darwin"* ]]; then CUT_FLAG=8; fi;  # -f 8 for OSX, -f 5 for linux
	AUDIO_FLAC_FILESIZE=$(ls -l "$AUDIO_FLAC_FILEPATH" | cut -d' ' -f $CUT_FLAG)

	EXEC_AUDIO_COMPRESS=$(gzip -q "$AUDIO_FLAC_FILEPATH")

	NOW=$(($(date +%s)*1000))

	CHECKIN_JSON="{\"queued_at\":$NOW,\"measured_at\":$NOW,\"audio\":\"$NOW*$DATETIME_EPOCH*flac*$AUDIO_FLAC_SHA1*$AUDIO_SAMPLE_RATE*16384*flac*vbr*10000\",\"queued_checkins\":\"1\",\"skipped_checkins\":\"0\",\"stashed_checkins\":\"0\"}"
	CHECKIN_JSON_ZIPPED=$(echo "$CHECKIN_JSON" | gzip | base64)
	echo $CHECKIN_JSON

	curl -X POST "https://api.rfcx.org/v1/guardians/$GUARDIAN_GUID/checkins" -H "cache-control: no-cache" -H "x-auth-user: guardian/$GUARDIAN_GUID" -H "x-auth-token: $GUARDIAN_TOKEN" -H "content-type: multipart/form-data" -F "meta=$CHECKIN_JSON_ZIPPED" -F "audio=@$AUDIO_FLAC_FILEPATH.gz";

	echo "$AUDIO_ORIG_FILENAME - $AUDIO_SAMPLE_RATE - $AUDIO_SAMPLE_COUNT - $AUDIO_FLAC_SHA1 - $AUDIO_FLAC_FILESIZE"

	echo "***** HI DAVID *****"

	# Post Cleanup
	EXEC_CLEANUP_POST=$(rm -f "$AUDIO_FLAC_FILEPATH" "$AUDIO_FLAC_FILEPATH.gz")

fi

