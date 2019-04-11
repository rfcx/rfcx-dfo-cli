#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";

LOGS_DIR="$SCRIPT_DIR/logs"; if [ ! -d $LOGS_DIR/archive ]; then mkdir -p $LOGS_DIR/archive; fi;

echo " - We archive log files here, if they're getting too big..."

