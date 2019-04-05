#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

SCRIPT_NAME=$1
#EXTRA_PARAM=$2

read AUDIO_FILEPATH

if [ -f "$AUDIO_FILEPATH" ]; then

	$SCRIPT_DIR/$SCRIPT_NAME.sh "$AUDIO_FILEPATH" #"$EXTRA_PARAM"

else

	echo "Error: '$AUDIO_FILEPATH' could not be found..."

fi