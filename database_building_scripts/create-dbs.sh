#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

SQL_DIR="$1"
if [ -z "$SQL_DIR" ] ; then
    echo "No SQL directory"  1>&2
    exit 1
fi

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json

SUFFIX=".sql.gz"

DB_DIR=$SQL_DIR/../dbs/
mkdir -p $DB_DIR

COUNT=0
for F in $(find $SQL_DIR/ -type f | sort | grep "iTunes-\d\d\d\d-\d\d-\d\d$SUFFIX") ; do
  NAME=`basename -s"$SUFFIX" $F`
  echo "Processing $NAME"
  gzip -cd $F | sqlite3 > $DB_DIR/$NAME.db &
  let COUNT++
  if [ $COUNT -eq 7 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done
