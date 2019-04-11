#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
LOGS_DIR="$APP_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;

TRIGGER_SCRIPT_NAME=$1
TIMEOUT=$2
PARAM_1=$3
PARAM_2=$4

$APP_DIR/trigger_$TRIGGER_SCRIPT_NAME.sh "$PARAM_1" "$PARAM_2" &
PID=$!
echo " - Launched '$TRIGGER_SCRIPT_NAME' in background (Process $PID, Max $TIMEOUT secs)"

sleep $TIMEOUT
KILL=$(kill -9 $PID)

