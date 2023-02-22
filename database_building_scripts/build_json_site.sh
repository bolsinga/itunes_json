#!/bin/sh -e

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

JSON_DIR="$2"
if [ -z "$JSON_DIR" ] ; then
  echo "No json_dir" 1>&2
  exit 1
fi

rm -rf $SITE_DIR/*

cp -a $HOME/Documents/code/git/web_data/html/ $SITE_DIR

# JAVA_OPTS="-Dweb.debug_output=true"
$HOME/Applications/web_generator/site json-site $SITE_DIR $HOME/Documents/code/git/web_data/settings.properties $JSON_DIR
if_failure "Cannot create site locally"
