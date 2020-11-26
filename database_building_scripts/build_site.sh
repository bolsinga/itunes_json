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

rm /tmp/itunes-*.json

MDATE=`date "+%Y-%m-%d-%H:%M:%S"`
ITUNES_JSON_FILE=/tmp/itunes-$MDATE.json

$HOME/Applications/itunes_json/Products/usr/local/bin/itunes_json > $ITUNES_JSON_FILE
if_failure "Cannot create itunes json file: $ITUNES_JSON_FILE"

$HOME/Applications/web_generator/site $HOME/Documents/code/git/web_data $SITE_DIR site $ITUNES_JSON_FILE
if_failure "Cannot create site locally"
