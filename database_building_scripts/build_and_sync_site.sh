#!/bin/sh

if_failure ()
{
  if [ "$?" -ne 0 ] ; then
    echo "$0: Failure Error: $1" 1>&2
    exit 1
  fi
}

PRG="$0"
PROG_HOME=`dirname "$PRG"`
PROG_HOME=`cd "$PROG_HOME" && pwd`

SITE_DIR=$HOME/Sites

$PROG_HOME/build_site.sh $SITE_DIR
if_failure "Cannot build site"

rsync -avzr --delete $SITE_DIR/* mink.he.net:/home/bolsinga/public_html
if_failure "Cannot update web site"
