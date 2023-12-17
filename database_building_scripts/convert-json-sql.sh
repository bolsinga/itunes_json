#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

BKUP_DIR="$1"
if [ -z "$BKUP_DIR" ] ; then
    echo "No backup directory"  1>&2
    exit 1
fi

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json

SUFFIX=".json.gz"

SQL_DIR=$BKUP_DIR/../sql/
mkdir -p $SQL_DIR

COUNT=0
for F in $(find $BKUP_DIR/ -type f | sort | grep "iTunes-\d\d\d\d-\d\d-\d\d$SUFFIX") ; do
  NAME=`basename -s"$SUFFIX" $F`
  echo "Processing $NAME"
  gzip -cd $F | $JSON_TOOL --json-string --sql-code - | gzip -c > $SQL_DIR/$NAME.sql.gz &
  let COUNT++
  if [ $COUNT -eq 5 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done
