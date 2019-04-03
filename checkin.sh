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
	API_HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;

	read FILEPATH_ORIG
	FILENAME_ORIG=$(basename -- "$FILEPATH_ORIG")
	FILEXT_ORIG=$(echo $FILENAME_ORIG | rev | cut -d'.' -f 1 | rev)

	FILENAME_FORMAT=`cat "$SCRIPT_DIR/filename_format";`;

	read -r EPOCH_SEC <<< "$(date -jf "$FILENAME_FORMAT.$FILEXT_ORIG" '+%s' "$FILENAME_ORIG")"

	EPOCH_MS=$((EPOCH_SEC*1000))
	AUDIO_FLAC_FILEPATH="$TMP_DIR/$EPOCH_MS.flac"

	# Pre Cleanup
	EXEC_CLEANUP_PRE=$(rm -f "$AUDIO_FLAC_FILEPATH" "$AUDIO_FLAC_FILEPATH.gz")

	AUDIO_SAMPLE_RATE=$(soxi -r "$FILEPATH_ORIG")
	EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$FILEPATH_ORIG" -ar "$AUDIO_SAMPLE_RATE" "$AUDIO_FLAC_FILEPATH")
	AUDIO_FLAC_SHA1=$(openssl dgst -sha1 "$AUDIO_FLAC_FILEPATH" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

	CUT_FLAG=5; if [[ "$OSTYPE" == "darwin"* ]]; then CUT_FLAG=8; fi;  # -f 8 for OSX, -f 5 for linux
	AUDIO_FLAC_FILESIZE=$(ls -l "$AUDIO_FLAC_FILEPATH" | cut -d' ' -f $CUT_FLAG)

	EXEC_AUDIO_COMPRESS=$(gzip -q "$AUDIO_FLAC_FILEPATH")

	NOW=$(($(date +%s)*1000))

	CHECKIN_JSON="{\"audio\":\"$NOW*$EPOCH_MS*flac*$AUDIO_FLAC_SHA1*$AUDIO_SAMPLE_RATE*16384*flac*vbr*10000\",\"queued_at\":$NOW,\"measured_at\":$NOW,\"queued_checkins\":\"1\",\"skipped_checkins\":\"0\",\"stashed_checkins\":\"0\"}"
	CHECKIN_JSON_ZIPPED=$(echo "$CHECKIN_JSON" | gzip | base64)
	echo $CHECKIN_JSON
	# CHECKIN_AUDIO_ZIPPED=$(base64 "$AUDIO_FLAC_FILEPATH.gz")
	# echo $CHECKIN_AUDIO_ZIPPED

	curl -X POST "https://$API_HOSTNAME/v1/guardians/$GUARDIAN_GUID/checkins" -H "cache-control: no-cache" -H "x-auth-user: guardian/$GUARDIAN_GUID" -H "x-auth-token: $GUARDIAN_TOKEN" -H "content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" -F "audio=@$AUDIO_FLAC_FILEPATH.gz" -F "meta=$CHECKIN_JSON_ZIPPED";
	# curl -X POST "https://$API_HOSTNAME/v1/guardians/$GUARDIAN_GUID/checkins" -H "cache-control: no-cache" -H "x-auth-user: guardian/$GUARDIAN_GUID" -H "x-auth-token: $GUARDIAN_TOKEN" -H "content-type: application/x-www-form-urlencoded" -d "meta=$CHECKIN_JSON_ZIPPED&audio=$CHECKIN_AUDIO_ZIPPED";

	echo ""; echo "$FILENAME_ORIG - $AUDIO_SAMPLE_RATE - $AUDIO_FLAC_SHA1 - $AUDIO_FLAC_FILESIZE"

	# Post Cleanup
	# EXEC_CLEANUP_POST=$(rm -f "$AUDIO_FLAC_FILEPATH" "$AUDIO_FLAC_FILEPATH.gz")

fi

