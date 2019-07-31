#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;

GUARDIAN_LAT_LNG="[not set]";
if [ -f "$PRIVATE_DIR/prefs_latitude_longitude" ]; then
	GUARDIAN_LAT_LNG=`cat "$PRIVATE_DIR/prefs_latitude_longitude";`;
fi

echo " - "
echo " - Latitude, Longitude is currently set to: $GUARDIAN_LAT_LNG";
read -p " - Would you like to [re]set the Latitude, Longitude? (y/n): " -n 1 -r
FORCE_SET_LAT_LNG="${REPLY}";
echo ""

if [ "$FORCE_SET_LAT_LNG" = "y" ]; then
	
		RESET_LAT_LNG=$(rm -rf $PRIVATE_DIR/prefs_latitude_longitude)

		echo " - "
		echo " - Please provide the geocoordinates (Format: Decimal Degrees - Example: 40.707,-95.356):"
		read -p " - Enter the Latitude: " -n 15 -r
		LAT="${REPLY}";
		read -p " - Enter the Longitude: " -n 15 -r
		LNG="${REPLY}";
		GUARDIAN_LAT_LNG="$LAT,$LNG"
		echo "$GUARDIAN_LAT_LNG" > "$PRIVATE_DIR/prefs_latitude_longitude"

fi

echo " - "
echo " - Latitude, Longitude set to: $GUARDIAN_LAT_LNG"
