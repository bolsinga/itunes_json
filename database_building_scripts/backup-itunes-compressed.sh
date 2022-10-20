#/bin/sh

DST_DIR="$1"
if [ -z "$DST_DIR" ] ; then
    echo "No destination directory"  1>&2
    exit 1
fi

MDATE=`date "+%Y-%m-%d"`

/Users/bolsinga/Applications/itunes_json/Products/usr/local/bin/itunes_json | gzip -c > $DST_DIR/iTunes-$MDATE.json.gz
