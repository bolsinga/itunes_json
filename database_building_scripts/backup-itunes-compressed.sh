#/bin/sh

checkFailure() {
  # $1 exit code
  # $2 message
  if [ $1 -ne 0 ] ; then
    echo "Command failed: $2"
    exit 1
  fi
}

DST_DIR="$1"
if [ -z "$DST_DIR" ] ; then
    echo "No destination directory"  1>&2
    exit 1
fi

PRG="$0"
PRG_HOME=`dirname "$PRG"`
PRG_HOME=`cd "$PRG_HOME" && pwd`

/Users/bolsinga/Applications/itunes_json/Products/usr/local/bin/itunes_json --time-test
RESULT=$?
if [ $RESULT -ne 0 ] ; then
  /usr/bin/osascript -e "display notification \"Result: $RESULT\" with title \"iTunes Backup Issue\" subtitle \"Time Test\""
fi

MDATE=`date "+%Y-%m-%d"`

MESSAGE=iTunes-$MDATE

DST_FILE=$DST_DIR/$MESSAGE.json.gz

/Users/bolsinga/Applications/itunes_json/Products/usr/local/bin/itunes_json | gzip -c > $DST_FILE

GIT_DIR=$DST_DIR/git/

pushd $GIT_DIR
git status
checkFailure $? "$GIT_DIR is not a git directory."

git checkout main
checkFailure $? "checkout main"

gzip -cd $DST_FILE > itunes.json
checkFailure $? gzip

$PRG_HOME/database-add-git.sh $GIT_DIR $MESSAGE
checkFailure $? database-git

git push --tags
checkFailure $? push

git gc --prune=now
popd
