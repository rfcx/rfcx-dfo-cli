#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..";

SCRIPT_NAME=$1
#EXTRA_PARAM=$2

read STDIN_PARAM

# echo " - Value: $STDIN_PARAM"
$SCRIPT_DIR/$SCRIPT_NAME.sh "$STDIN_PARAM" #"$EXTRA_PARAM"
