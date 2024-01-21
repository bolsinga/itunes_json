#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

BKUP_DIR="$1"
if [ -z "$BKUP_DIR" ] ; then
    echo "No backup directory" 1>&2
    exit 1
fi

REPAIR_DIR="$2"
if [ -z "$REPAIR_DIR" ] ; then
    echo "No destination directory" 1>&2
    exit 1
fi

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json

SUFFIX=".json.gz"

mkdir -p $REPAIR_DIR

REPAIR=`cat ~/Documents/code/git/web_data/itunes-repair.json`

COUNT=0
for F in $(find $BKUP_DIR/ -type f | sort | grep "iTunes-\d\d\d\d-\d\d-\d\d$SUFFIX") ; do
  NAME=`basename -s"$SUFFIX" $F`
  echo "Processing $NAME"
  gzip -cd $F | $JSON_TOOL --repair-source "$REPAIR" --json-string --json - | gzip -c > $REPAIR_DIR/$NAME$SUFFIX &
  let COUNT++
  if [ $COUNT -eq 7 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done
