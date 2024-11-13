#/bin/sh

#  ~/bin/itunes-db-snapshot.sh | sqlite3 /tmp/now.db

JSON_TOOL=~/Applications/iTunesJson.app/Contents/MacOS/iTunesJson

$JSON_TOOL --itunes --sql-code 
