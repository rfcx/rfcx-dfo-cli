#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..";

PRIVATE_DIR="$APP_DIR/.private"; if [ ! -d $PRIVATE_DIR ]; then mkdir -p $PRIVATE_DIR; fi;


if [ ! -f "$PRIVATE_DIR/guardian_latitude_longitude" ]; then
	echo " - Please provide the geocoordinates (Format: Decimal Degrees - Example: 40.707,-95.356):"
	read -p " - Enter the Latitude: " -n 15 -r
	LAT="${REPLY}";
	read -p " - Enter the Longitude: " -n 15 -r
	LNG="${REPLY}";
	GUARDIAN_LAT_LNG="$LAT,$LNG"
	echo "$GUARDIAN_LAT_LNG" > "$PRIVATE_DIR/guardian_latitude_longitude"
else
	GUARDIAN_LAT_LNG=`cat "$PRIVATE_DIR/guardian_latitude_longitude";`;
fi 

echo " - Latitude, Longitude: $GUARDIAN_LAT_LNG"
