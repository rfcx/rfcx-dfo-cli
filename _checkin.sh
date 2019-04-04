#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

AUDIO_DIR=$1;

AUDIO_FILEPATH=$(ls -d $AUDIO_DIR/* | head -1)

echo $AUDIO_FILEPATH | $SCRIPT_DIR/checkin.sh;