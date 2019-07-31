#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
TMP_DIR="$APP_DIR/tmp"; if [ ! -d $TMP_DIR ]; then mkdir -p $TMP_DIR; fi;
DB_DIR="$APP_DIR/databases"; if [ ! -d $DB_DIR ]; then mkdir -p $DB_DIR; fi;
LOGS_DIR="$APP_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;
PRIVATE_DIR="$APP_DIR/.private"

# Environmental Customizations
GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;
GNU_STAT_FLAG="-c%s"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_STAT_FLAG="-f%z"; fi;
GNU_BASE64_FLAG="-w0"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_BASE64_FLAG=""; fi;

# check if guardian has been set up
if [ ! -f "$PRIVATE_DIR/guardian_guid" ]; then 

	echo "No CheckIn because no guid/credentials have been set. Please run 'setup.sh'."

else

	GUARDIAN_GUID=`cat "$PRIVATE_DIR/guardian_guid";`;
	API_TOKEN=`cat "$PRIVATE_DIR/api_token";`;
	API_HOSTNAME=`cat "$PRIVATE_DIR/api_hostname";`;

	FILEPATH_ORIG=$1
	FILENAME_TIMESTAMP_FORMAT=$2

	if [ -f "$FILEPATH_ORIG" ]; then

		FILESIZE_ORIG=$(($(stat $GNU_STAT_FLAG "$FILEPATH_ORIG")))

		if [ "$FILESIZE_ORIG" -gt "0" ]; then

			FILENAME_ORIG=$(basename -- "$FILEPATH_ORIG")

			CODEC_ORIG=$(echo $FILENAME_ORIG | rev | cut -d'.' -f 1 | rev | tr '[:upper:]' '[:lower:]')
			
			if [ "$CODEC_ORIG" = "wav" ]; then CODEC_FINAL="flac"; else CODEC_FINAL="$CODEC_ORIG"; fi;

			echo " - ";
			echo " - Audio: $FILENAME_ORIG (Pattern: $FILENAME_TIMESTAMP_FORMAT) (Guardian: $GUARDIAN_GUID)";
			
			STR_OFFSET_YEAR=${FILENAME_TIMESTAMP_FORMAT/\%Y*/}; OFFSET_YEAR=${#STR_OFFSET_YEAR};
			STR_OFFSET_MONTH=${FILENAME_TIMESTAMP_FORMAT/\%m*/}; OFFSET_MONTH=${#STR_OFFSET_MONTH};
			STR_OFFSET_DAY=${FILENAME_TIMESTAMP_FORMAT/\%d*/}; OFFSET_DAY=${#STR_OFFSET_DAY};
			STR_OFFSET_HOUR=${FILENAME_TIMESTAMP_FORMAT/\%H*/}; OFFSET_HOUR=${#STR_OFFSET_HOUR};
			STR_OFFSET_MIN=${FILENAME_TIMESTAMP_FORMAT/\%M*/}; OFFSET_MIN=${#STR_OFFSET_MIN};
			STR_OFFSET_SEC=${FILENAME_TIMESTAMP_FORMAT/\%S*/}; OFFSET_SEC=${#STR_OFFSET_SEC};

			MILLISECONDS=0;
			MILLISECONDS_PADDED=$(printf %03d $MILLISECONDS)

			# SYSTEM_TIMEZONE_OFFSET=$($GNU_DATE_BIN '+%z')
			SYSTEM_TIMEZONE_OFFSET="+0000"

			DATETIME_ISO="${FILENAME_ORIG:OFFSET_YEAR:4}-${FILENAME_ORIG:OFFSET_MONTH:2}-${FILENAME_ORIG:OFFSET_DAY:2}T${FILENAME_ORIG:OFFSET_HOUR:2}:${FILENAME_ORIG:OFFSET_MIN:2}:${FILENAME_ORIG:OFFSET_SEC:2}.${MILLISECONDS_PADDED}${SYSTEM_TIMEZONE_OFFSET}";
			DATETIME_EPOCH=$(($($GNU_DATE_BIN --date="$DATETIME_ISO" '+%s')*1000+$MILLISECONDS))

			AUDIO_ORIG_COPY_FILEPATH="$TMP_DIR/$DATETIME_EPOCH_tmp.$CODEC_ORIG"
			AUDIO_FINAL_FILEPATH="$TMP_DIR/$DATETIME_EPOCH.$CODEC_FINAL"

			# Pre Cleanup
			EXEC_CLEANUP_PRE=$(rm -f "$AUDIO_FINAL_FILEPATH" "$AUDIO_ORIG_COPY_FILEPATH" "$AUDIO_FINAL_FILEPATH.gz")

			EXEC_COPY_ORIG=$(cp "$FILEPATH_ORIG" "$AUDIO_ORIG_COPY_FILEPATH")

			AUDIO_SAMPLE_PRECISION=16
			AUDIO_CHANNEL_COUNT=1

			if [ "$CODEC_ORIG" = "wav" ]; then 
				AUDIO_SAMPLE_RATE=$(soxi -r "$AUDIO_ORIG_COPY_FILEPATH")
				# AUDIO_SAMPLE_PRECISION=$(soxi -p "$AUDIO_ORIG_COPY_FILEPATH")
				# AUDIO_CHANNEL_COUNT=$(soxi -c "$AUDIO_ORIG_COPY_FILEPATH")
				EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$AUDIO_ORIG_COPY_FILEPATH" -ar "$AUDIO_SAMPLE_RATE" -ac "$AUDIO_CHANNEL_COUNT" "$AUDIO_FINAL_FILEPATH")
			else
				AUDIO_TEMP_FILEPATH="$TMP_DIR/$DATETIME_EPOCH.wav"
				EXEC_CLEANUP_TEMP=$(rm -f "$AUDIO_TEMP_FILEPATH")
				EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$AUDIO_ORIG_COPY_FILEPATH" "$AUDIO_TEMP_FILEPATH")
				AUDIO_SAMPLE_RATE=$(soxi -r "$AUDIO_TEMP_FILEPATH")
				# AUDIO_SAMPLE_PRECISION=$(soxi -p "$AUDIO_TEMP_FILEPATH")
				# AUDIO_CHANNEL_COUNT=$(soxi -c "$AUDIO_TEMP_FILEPATH")
				EXEC_CLEANUP_TEMP=$(rm -f "$AUDIO_TEMP_FILEPATH")
				cp "$AUDIO_ORIG_COPY_FILEPATH" "$AUDIO_FINAL_FILEPATH";
			fi

			# EXEC_AUDIO_CONVERT=$(ffmpeg -loglevel panic -i "$FILEPATH_ORIG" -ar "$AUDIO_SAMPLE_RATE" "$AUDIO_FINAL_FILEPATH")
			AUDIO_FINAL_SHA1=$(openssl dgst -sha1 "$AUDIO_FINAL_FILEPATH" | grep 'SHA1(' | cut -d'=' -f 2 | cut -d' ' -f 2)

			AUDIO_FINAL_FILESIZE=$(stat $GNU_STAT_FLAG "$AUDIO_FINAL_FILEPATH")

			EXEC_AUDIO_COMPRESS=$(gzip -c "$AUDIO_FINAL_FILEPATH" > "$AUDIO_FINAL_FILEPATH.gz")

			SENT_AT_EPOCH=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))
			CHECKIN_JSON="{\"audio\":\"$SENT_AT_EPOCH*$DATETIME_EPOCH*$CODEC_FINAL*$AUDIO_FINAL_SHA1*$AUDIO_SAMPLE_RATE*1*$CODEC_FINAL*vbr*1*${AUDIO_SAMPLE_PRECISION}bit\",\"queued_at\":$SENT_AT_EPOCH,\"measured_at\":$SENT_AT_EPOCH,\"software\":\"guardian-cli*0.1.0|updater-cli*0.1.0\",\"battery\":\"$SENT_AT_EPOCH*100*0\",\"queued_checkins\":\"1\",\"skipped_checkins\":\"0\",\"stashed_checkins\":\"0\"}"
			CHECKIN_JSON_ZIPPED=$(echo -n "$CHECKIN_JSON" | gzip -c | base64 $GNU_BASE64_FLAG | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g') 

			echo " - Timestamp: $DATETIME_ISO ($DATETIME_EPOCH)";
			echo " - Codec: $CODEC_FINAL — Sample Rate: $AUDIO_SAMPLE_RATE Hz — File Size: $AUDIO_FINAL_FILESIZE bytes";
			# echo " - JSON: $CHECKIN_JSON"

			EXEC_CHECKIN=$(curl -X POST -H "x-auth-user: guardian/$GUARDIAN_GUID" -H "x-auth-token: $API_TOKEN" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "meta=${CHECKIN_JSON_ZIPPED}" -F "audio=@${AUDIO_FINAL_FILEPATH}.gz" "$API_HOSTNAME/v1/guardians/$GUARDIAN_GUID/checkins" 2>$LOGS_DIR/error_checkin_curl.log)

			if [[ $EXEC_CHECKIN == *"checkin_id"* ]]; then

				COMPLETED_AT_EPOCH=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))
				CHECKIN_LATENCY=$(($COMPLETED_AT_EPOCH-$SENT_AT_EPOCH))

				CHECKIN_GUID=$($APP_DIR/utils/json_parse.sh 'checkin_id' $EXEC_CHECKIN);
				AUDIO_GUID=$($APP_DIR/utils/json_parse.sh 'guid' $EXEC_CHECKIN);

				echo " - CheckIn: $CHECKIN_GUID - Audio: $AUDIO_GUID - Latency: $CHECKIN_LATENCY ms"
				# echo " - JSON: $EXEC_CHECKIN";
				
				# add/remove entries from local databases
				if [ -f "$DB_DIR/checkins-complete.db" ]; then
					ADD_TO_COMPLETE=$(sqlite3 "$DB_DIR/checkins-complete.db" "INSERT INTO complete (sent_at, completed_at, filename, audio_id, checkin_id, latency) VALUES ($SENT_AT_EPOCH, $COMPLETED_AT_EPOCH, '$FILENAME_ORIG', '$AUDIO_GUID', '$CHECKIN_GUID', $CHECKIN_LATENCY);";)
					if [ -f "$DB_DIR/checkins-sent.db" ]; then
						REMOVE_FROM_SENT=$(sqlite3 "$DB_DIR/checkins-sent.db" "DELETE FROM sent WHERE filename='$FILENAME_ORIG';";)
					fi
				fi

			else
				echo " - Check in was NOT successful..."
				echo " - Response: $EXEC_CHECKIN"
			fi

		else
			echo " - '$FILEPATH_ORIG' contains no data (0 bytes)..."
		fi

	else
		echo " - '$FILEPATH_ORIG' could not be found..."
	fi

	# Post Cleanup
	EXEC_CLEANUP_POST=$(rm -f "$AUDIO_FINAL_FILEPATH" "$AUDIO_ORIG_COPY_FILEPATH" "$AUDIO_FINAL_FILEPATH.gz")

fi

