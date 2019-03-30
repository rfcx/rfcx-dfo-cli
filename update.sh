#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

if [ ! -d "$SCRIPT_DIR/.git" ]; then 

	echo "updating checkin script...";

	wget -O "$SCRIPT_DIR/checkin.sh" https://raw.githubusercontent.com/rfcx/rfcx-dfo-cli/master/checkin.sh

else

	echo "not updating because this is a git repository";

fi

chmod a+x "$SCRIPT_DIR/checkin.sh";

PRIVATE_DIR="$SCRIPT_DIR/.private"
GUID=`cat "$PRIVATE_DIR/guid";`;
TOKEN=`cat "$PRIVATE_DIR/token";`;
NOW=$(($(date +%s)*1000))

curl -X GET "https://api.rfcx.org/v1/guardians/$GUID/software/all?role=updater&version=0.4.0&battery=100&timestamp=$NOW" -H "cache-control: no-cache" -H "x-auth-user: guardian/$GUID" -H "x-auth-token: $TOKEN";


