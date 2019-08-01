#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

GUARDIAN_LAT_LNG="[not set]";
if [ -f "$PRIVATE_DIR/prefs_latitude" ]; then
	GUARDIAN_LAT=`cat "$PRIVATE_DIR/prefs_latitude";`;
	if [ -f "$PRIVATE_DIR/prefs_longitude" ]; then
		GUARDIAN_LNG=`cat "$PRIVATE_DIR/prefs_longitude";`;
		GUARDIAN_LAT_LNG="$GUARDIAN_LAT,$GUARDIAN_LNG";
	fi
fi

echo " - "
echo " - Latitude, Longitude is currently set to: $GUARDIAN_LAT_LNG";
read -p " - Would you like to [re]set the Latitude, Longitude? (y/n): " -n 1 -r
FORCE_SET_LAT_LNG="${REPLY}";
echo ""

if [ "$FORCE_SET_LAT_LNG" = "y" ]; then
	
		RESET_LAT_LNG=$(rm -rf $PRIVATE_DIR/prefs_latitude $PRIVATE_DIR/prefs_longitude)

		echo " - "
		echo " - Please provide the geocoordinates (Format: Decimal Degrees — Example: 40.707,-95.356):"
		read -p " - Enter Latitude: " -n 15 -r
		LAT="${REPLY}";
		LAT=$(echo -e "${LAT}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
		echo "$LAT" > "$PRIVATE_DIR/prefs_latitude"
		read -p " - Enter Longitude: " -n 15 -r
		LNG="${REPLY}";
		LNG=$(echo -e "${LNG}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
		echo "$LNG" > "$PRIVATE_DIR/prefs_longitude"
		GUARDIAN_LAT_LNG="$LAT,$LNG"

fi

echo " - "
echo " - Latitude, Longitude set to: $GUARDIAN_LAT_LNG"
