#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

BKUP_DIR="$1"
if [ -z "$BKUP_DIR" ] ; then
    echo "No backup directory" 1>&2
    exit 1
fi

DST_DIR="$2"
if [ -z "$DST_DIR" ] ; then
    echo "No destination directory" 1>&2
    exit 1
fi

ARTIST_FILTER="$3"

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json

mkdir -p $DST_DIR

REPAIR_FILE=~/Documents/code/git/web_data/itunes-repair.json
REPAIR=`cat $REPAIR_FILE`

pushd $BKUP_DIR

COUNT=0
for NAME in $(git tag --list | grep -v empty | sort) ; do
  echo "Processing $NAME"
  git checkout $NAME
  cat itunes.json | $JSON_TOOL --artist-name-filter "${ARTIST_FILTER}" --logging-token $NAME --repair-source "$REPAIR" --json-string --sql-code - | tee >(gzip -c > $DST_DIR/$NAME.sql.gz) | sqlite3 $DST_DIR/$NAME.db

  let COUNT++
  if [ $COUNT -eq 7 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done

git checkout main

popd
