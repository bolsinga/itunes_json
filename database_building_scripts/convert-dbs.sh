#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

BKUP_DIR="$1"
if [ -z "$BKUP_DIR" ] ; then
    echo "No backup directory"  1>&2
    exit 1
fi

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json

SUFFIX=".json.gz"

DB_DIR=$BKUP_DIR/../dbs/
mkdir -p $DB_DIR

createDbArchive() {
  # $1 file
  local NAME=`basename -s"$SUFFIX" $1`
  local DB_NAME_DIR="$DB_DIR/$NAME"
  mkdir -p $DB_NAME_DIR
  echo "Processing $NAME"
  gzip -cd $1 | $JSON_TOOL --json-string --db --output-directory $DB_NAME_DIR --file-name $NAME -
  tar czf $DB_NAME_DIR.tar.gz -C $DB_DIR $NAME
  if [ $? -eq 0 ] ; then
    rm -rf $DB_NAME_DIR
  fi
}

COUNT=0
for F in $(find $BKUP_DIR/ -type f | sort | grep "iTunes-\d\d\d\d-\d\d-\d\d$SUFFIX") ; do
  createDbArchive $F &

  let COUNT++
  if [ $COUNT -eq 7 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done
