#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

TMP_DIR="$SCRIPT_DIR/tmp"
if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi

PRIVATE_DIR="$SCRIPT_DIR/.private"

# Environmental Customizations
LS_FILESIZE_CUT=5; if [[ "$OSTYPE" == "darwin"* ]]; then LS_FILESIZE_CUT=8; fi;
GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;

# check if guardian has been set up
if [ ! -f "$PRIVATE_DIR/guid" ]; then 

	echo "No Check In because no guid/credentials have been set. Please run 'setup.sh'."

else

	GUARDIAN_GUID=`cat "$PRIVATE_DIR/guid";`;
	GUARDIAN_TOKEN=`cat "$PRIVATE_DIR/token";`;
	API_HOSTNAME=`cat "$PRIVATE_DIR/hostname";`;

	read FILEPATH_ORIG
	FILENAME_ORIG=$(basename -- "$FILEPATH_ORIG")
	FILEXT_ORIG=$(echo $FILENAME_ORIG | rev | cut -d'.' -f 1 | rev)

	FORMAT="SCW1840_%Y%Y%m%d_%H%M%S"

	STR_OFFSET_YEAR=${FORMAT/\%Y*/}; OFFSET_YEAR=${#STR_OFFSET_YEAR};
	STR_OFFSET_MONTH=${FORMAT/\%m*/}; OFFSET_MONTH=${#STR_OFFSET_MONTH};
	STR_OFFSET_DAY=${FORMAT/\%d*/}; OFFSET_DAY=${#STR_OFFSET_DAY};
	STR_OFFSET_HOUR=${FORMAT/\%H*/}; OFFSET_HOUR=${#STR_OFFSET_HOUR};
	STR_OFFSET_MIN=${FORMAT/\%M*/}; OFFSET_MIN=${#STR_OFFSET_MIN};
	STR_OFFSET_SEC=${FORMAT/\%S*/}; OFFSET_SEC=${#STR_OFFSET_SEC};

	SYSTEM_TIMEZONE_OFFSET=$($GNU_DATE_BIN '+%z')
	DATETIME_PARSEABLE="${FILENAME_ORIG:OFFSET_YEAR:4}-${FILENAME_ORIG:OFFSET_MONTH:2}-${FILENAME_ORIG:OFFSET_DAY:2}T${FILENAME_ORIG:OFFSET_HOUR:2}:${FILENAME_ORIG:OFFSET_MIN:2}:${FILENAME_ORIG:OFFSET_SEC:2}${SYSTEM_TIMEZONE_OFFSET}";
	
	read -r EPOCH_SEC <<< "$($GNU_DATE_BIN --date="$DATETIME_PARSEABLE" '+%s')"
	EPOCH_MS=$((EPOCH_SEC*1000))

	AUDIO_FLAC_FILEPATH="$TMP_DIR/$EPOCH_MS.flac"

	# Pre Cleanup
	EXEC_CLEANUP_PRE=$(rm -f "$AUDIO_FLAC_FILEPATH" "$AUDIO_FLAC_FILEPATH.gz")

	AUDIO_SAMPLE_RATE=$(soxi -r "$FILEPATH_ORIG")
	EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$FILEPATH_ORIG" -ar "$AUDIO_SAMPLE_RATE" "$AUDIO_FLAC_FILEPATH")
	AUDIO_FLAC_SHA1=$(openssl dgst -sha1 "$AUDIO_FLAC_FILEPATH" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

	AUDIO_FLAC_FILESIZE=$(ls -l "$AUDIO_FLAC_FILEPATH" | cut -d' ' -f $LS_FILESIZE_CUT)

	EXEC_AUDIO_COMPRESS=$(gzip --quiet --best --suffix .gz $AUDIO_FLAC_FILEPATH)

	NOW=$(($($GNU_DATE_BIN '+%s')*1000))

	CHECKIN_JSON="{\"audio\":\"$NOW*$EPOCH_MS*flac*$AUDIO_FLAC_SHA1*$AUDIO_SAMPLE_RATE*16384*flac*vbr*10000\",\"queued_at\":$NOW,\"measured_at\":$NOW,\"queued_checkins\":\"1\",\"skipped_checkins\":\"0\",\"stashed_checkins\":\"0\",\"phone\":{\"sim\":\"8901260752765550548\",\"imei\":\"355093040407583\",\"imsi\":\"310260756555054\"},\"disk_usage\":\"internal*1553895616197*112287744*65970176|external*1553895616197*3145728*15641608192|internal*1553895177504*112287744*65970176|external*1553895177504*2752512*15642001408\",\"hardware\":{\"product\":\"u8150\",\"brand\":\"huawei\",\"model\":\"U8150\",\"android\":\"2.3.7\",\"manufacturer\":\"Huawei\"}}"
	CHECKIN_JSON_ZIPPED=$(echo -n "$CHECKIN_JSON" | gzip | base64)

	echo "$FILENAME_ORIG - $DATETIME_PARSEABLE - $AUDIO_SAMPLE_RATE - $AUDIO_FLAC_SHA1 - $AUDIO_FLAC_FILESIZE";

	curl "https://$API_HOSTNAME/v1/guardians/$GUARDIAN_GUID/checkins" -H "x-auth-user: guardian/$GUARDIAN_GUID" -H "x-auth-token: $GUARDIAN_TOKEN" -H "content-type: multipart/form-data" -F "meta=$CHECKIN_JSON_ZIPPED" -F "audio=@$AUDIO_FLAC_FILEPATH.gz"
	# curl -X POST "https://$API_HOSTNAME/v1/guardians/$GUARDIAN_GUID/checkins" -H "cache-control: no-cache" -H "x-auth-user: guardian/$GUARDIAN_GUID" -H "x-auth-token: $GUARDIAN_TOKEN" -H "content-type: application/x-www-form-urlencoded" -d "meta=$CHECKIN_JSON_ZIPPED&audio=$CHECKIN_AUDIO_ZIPPED";
	
	echo "";

	# Post Cleanup
	# EXEC_CLEANUP_POST=$(rm -f "$AUDIO_FLAC_FILEPATH" "$AUDIO_FLAC_FILEPATH.gz")

fi

