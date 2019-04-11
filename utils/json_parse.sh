#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/usr/bin:/opt/usr/sbin:/usr/local/bin:usr/local/sbin:$PATH"

# Code adapted from:
# https://stackoverflow.com/questions/1955505/parsing-json-with-unix-tools

# MAJOR LIMITATIONS
# This currently ONLY parses string values from json
# JSON Blob must use double-quotes 

ATTRIBUTE_NAME=$1;
JSON_BLOB=$2;

echo $JSON_BLOB | grep -Eo "\"$ATTRIBUTE_NAME\":.*?[^\\]\"" | cut -d':' -f 2 | cut -d'"' -f 2;
