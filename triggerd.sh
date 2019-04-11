#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
LOGS_DIR="$SCRIPT_DIR/logs"; if [ ! -d $LOGS_DIR ]; then mkdir -p $LOGS_DIR; fi;

TRIGGER_SCRIPT_NAME=$1
TIMEOUT=$2
PARAM_1=$3
PARAM_2=$4

$SCRIPT_DIR/trigger_$TRIGGER_SCRIPT_NAME.sh "\"$PARAM_1\"" "\"$PARAM_2\"" &
PID=$!
echo " - Sending '$TRIGGER_SCRIPT_NAME' into background. (Process ID $PID)"
echo " - Process will be killed if it runs longer than $TIMEOUT seconds."

sleep $TIMEOUT
KILL=$(kill -9 $PID)

