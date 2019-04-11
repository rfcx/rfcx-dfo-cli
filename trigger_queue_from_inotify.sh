#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

TARGET_DIRECTORY=$1
TARGET_FILETYPE=$2

if [ -d "$TARGET_DIRECTORY" ]; then 
	
	REGEX_FILTER=".*\.$TARGET_FILETYPE$"

	for i in {1..10}
	do
		inotifywait --event moved_to --format "%w%f" "$TARGET_DIRECTORY" | grep --line-buffered $REGEX_FILTER | $SCRIPT_DIR/stdin.sh "queue"
		echo " - "
	done

else

	echo " - "
	echo " - Directory '$TARGET_DIRECTORY' could not be found..."
	echo " - ."

fi

