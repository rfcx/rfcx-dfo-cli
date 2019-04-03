#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

AUDIO_DIR=$1;

ls -d $AUDIO_DIR/* | head -2 | $SCRIPT_DIR/checkin.sh;