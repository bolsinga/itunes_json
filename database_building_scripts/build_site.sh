#!/bin/sh

if_failure ()
{
  if [ "$?" -ne 0 ] ; then
    echo "$0: Failure Error: $1" 1>&2
    exit 1
  fi
}

SITE_DIR="$1"
if [ -z "$SITE_DIR" ] ; then
    echo "No site_dir"  1>&2
    exit 1
fi

rm -rf $SITE_DIR/*

rm /tmp/itunes-*.json

MDATE=`date "+%Y-%m-%d-%H:%M:%S"`
ITUNES_JSON_FILE=/tmp/itunes-$MDATE.json

$HOME/Applications/itunes_json/Products/usr/local/bin/itunes_json > $ITUNES_JSON_FILE
if_failure "Cannot create itunes json file: $ITUNES_JSON_FILE"

cp -a $HOME/Documents/code/git/web_data/html/ $SITE_DIR

# JAVA_OPTS="-Dweb.debug_output=true"
$HOME/Applications/web_generator/site site $SITE_DIR $HOME/Documents/code/git/web_data $ITUNES_JSON_FILE
if_failure "Cannot create site locally"
