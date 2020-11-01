#!/bin/sh
MDATE=`date "+%Y-%m-%d"`
$HOME/Applications/itunes_json/Products/usr/local/bin/itunes_json > $HOME/Documents/code/itunes_backups/iTunes-$MDATE.json
