#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";


GNU_DATE_BIN="date"; if [[ "$OSTYPE" == "darwin"* ]]; then GNU_DATE_BIN="gdate"; fi;


SENT_AT_EPOCH=$(($($GNU_DATE_BIN '+%s%N' | cut -b1-13)+0))

# AUDIO_META="$SENT_AT_EPOCH*"
# AUDIO_META+="$DATETIME_EPOCH*"
# AUDIO_META+="$CODEC_FINAL*"
# AUDIO_META+="$AUDIO_FINAL_SHA1*"
# AUDIO_META+="$AUDIO_SAMPLE_RATE*"
# AUDIO_META+="1*"
# AUDIO_META+="$CODEC_FINAL*"
# AUDIO_META+="vbr*"
# AUDIO_META+="1*"
# AUDIO_META+="${AUDIO_SAMPLE_PRECISION}bit"

# CHECKIN_JSON="{"
# CHECKIN_JSON+="\"audio\":\"$AUDIO_META\","
# CHECKIN_JSON+="\"queued_at\":$SENT_AT_EPOCH,"
# CHECKIN_JSON+="\"measured_at\":$SENT_AT_EPOCH,"
# CHECKIN_JSON+="\"software\":\"guardian-cli*0.1.0|updater-cli*0.1.0\","
# CHECKIN_JSON+="\"battery\":\"$SENT_AT_EPOCH*100*0\","
# CHECKIN_JSON+="\"queued_checkins\":\"1\","
# CHECKIN_JSON+="\"skipped_checkins\":\"0\","
# CHECKIN_JSON+="\"stashed_checkins\":\"0\""
# CHECKIN_JSON+="}"
		