#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
LOGS_DIR="$SCRIPT_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;

SCRIPT_EXECUTION_DURATION=15;

TRIGGER_SCRIPT_NAME=$1
PARAM_1=$2
PARAM_2=$3
# LOG_FILE="$LOGS_DIR/$TRIGGER_SCRIPT_NAME.log"

$SCRIPT_DIR/trigger_$TRIGGER_SCRIPT_NAME.sh "$PARAM_1" "$PARAM_2" &
PID=$!

sleep $SCRIPT_EXECUTION_DURATION
KILL=$(kill -9 $PID)

