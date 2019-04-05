#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

read AUDIO_FILEPATH

if [ -f "$AUDIO_FILEPATH" ]; then

	$SCRIPT_DIR/checkin.sh "$AUDIO_FILEPATH"

else

	echo "Error: '$AUDIO_FILEPATH' could not be found..."

fi