#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

BKUP_DIR="$1"
if [ -z "$BKUP_DIR" ] ; then
    echo "No backup directory"  1>&2
    exit 1
fi

DST_DIR="$2"
if [ -z "$DST_DIR" ] ; then
    echo "No destination directory" 1>&2
    exit 1
fi

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json
REPAIR=`cat ~/Documents/code/git/web_data/itunes-repair.json`

mkdir -p $DST_DIR

createDbArchive() {
  # $1 name
  local NAME=$1
  local DB_NAME_DIR="$DST_DIR/$NAME"
  mkdir -p $DB_NAME_DIR
  echo "Processing $NAME"
  cat itunes.json | $JSON_TOOL --repair-source "$REPAIR" --json-string --db --output-directory $DB_NAME_DIR --file-name $NAME -
  tar czf $DB_NAME_DIR.tar.gz -C $DST_DIR $NAME
  if [ $? -eq 0 ] ; then
    rm -rf $DB_NAME_DIR
  fi
}

pushd $BKUP_DIR

COUNT=0
for NAME in $(git tag --list | grep -v empty | sort) ; do
  createDbArchive $NAME &

  let COUNT++
  if [ $COUNT -eq 7 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done

git checkout main

popd
