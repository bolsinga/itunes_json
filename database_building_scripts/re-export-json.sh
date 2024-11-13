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

JSON_TOOL=~/Applications/iTunesJson.app/Contents/MacOS/iTunesJson

SUFFIX=".json.gz"

mkdir -p $DST_DIR

pushd $BKUP_DIR

COUNT=0
for NAME in $(git tag --list | grep -v empty | sort) ; do
  echo "Processing $NAME"
  git checkout $NAME

  cat itunes.json | $JSON_TOOL --logging-token $NAME --json-string --json - | gzip -c > $DST_DIR/$NAME$SUFFIX &
  let COUNT++
  if [ $COUNT -eq 7 ]; then
    echo Waiting for Batch
    wait
    let COUNT=0
  fi
done

git checkout main

popd
