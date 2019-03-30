#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

if [ ! -d "$SCRIPT_DIR/.git" ]; then 

	echo "updating rfcx_send_checkin script...";

	wget -O "$SCRIPT_DIR/rfcx_send_checkin.sh" https://raw.githubusercontent.com/rfcx/rfcx-dfo-cli/master/rfcx_send_checkin.sh

else

	echo "not updating because this is a git repository";

fi

chmod a+x "$SCRIPT_DIR/rfcx_send_checkin.sh";


