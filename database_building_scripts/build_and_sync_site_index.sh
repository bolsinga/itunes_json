#!/bin/sh

if_failure ()
{
  if [ "$?" -ne 0 ] ; then
    echo "$0: Failure Error: $1" 1>&2
    exit 1
  fi
}

MDATE=`date "+%Y-%m-%d-%H:%M:%S"`
ITUNES_JSON_FILE=/tmp/itunes-$MDATE.json

$HOME/Applications/itunes_json/Products/usr/local/bin/itunes_json > $ITUNES_JSON_FILE
if_failure "Cannot create itunes json file: $ITUNES_JSON_FILE"

$HOME/Applications/web_generator/site $HOME/Documents/code/git/web_data $HOME/Sites index $ITUNES_JSON_FILE
if_failure "Cannot create site locally"

rsync -avzr $HOME/Sites/* mink.he.net:/home/bolsinga/secure_html
if_failure "Cannot update web site"
