#/bin/sh

BKUP_DIR="$1"
if [ -z "$BKUP_DIR" ] ; then
    echo "No backup directory"  1>&2
    exit 1
fi

JSON_TOOL=~/Applications/itunes_json/Products/usr/local/bin/itunes_json

SUFFIX=".json.gz"

CONVERTED_DIR=$BKUP_DIR/../old-json/
mkdir -p $CONVERTED_DIR

UPDATED_DIR=$BKUP_DIR/../new-json/
mkdir -p $UPDATED_DIR

for F in $(find $BKUP_DIR/ -type f | sort | grep "iTunes-20[01]\d-\d\d-\d\d$SUFFIX") $(find $BKUP_DIR/ -type f | sort | grep "iTunes-2020-\d\d-01$SUFFIX") ; do
  NAME=`basename -s"$SUFFIX" $F`
  echo "Processing $NAME"
  gzip -cd $F | $JSON_TOOL --xml-json-string --json - | gzip -c > $UPDATED_DIR/$NAME$SUFFIX
  mv $F $CONVERTED_DIR
done
