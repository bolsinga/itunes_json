#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

SRC_DIR="$1"
if [ -z "$SRC_DIR" ] ; then
    echo "No source directory" 1>&2
    exit 1
fi

DST_DIR="$2"
if [ -z "$DST_DIR" ] ; then
    echo "No destination directory" 1>&2
    exit 1
fi

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json

SUFFIX=".json.gz"

mkdir -p $DST_DIR

COUNT=0
for F in $(find $SRC_DIR/ -type f | sort | grep "iTunes-\d\d\d\d-\d\d-\d\d$SUFFIX") ; do
  NAME=`basename -s"$SUFFIX" $F`
  echo "Processing $NAME"
  gzip -cd $F | $JSON_TOOL --json-string --json - | gzip -c > $DST_DIR/$NAME$SUFFIX &
  let COUNT++
  if [ $COUNT -eq 7 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done
