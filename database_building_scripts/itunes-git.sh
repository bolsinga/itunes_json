#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

SRC_DIR="$1"
if [ -z "$SRC_DIR" ] ; then
    echo "No source json directory"  1>&2
    exit 1
fi

GIT_DIR="$2"
if [ -z "$GIT_DIR" ] ; then
    echo "No destination git directory"  1>&2
    exit 1
fi

PRG="$0"
PRG_HOME=`dirname "$PRG"`
PRG_HOME=`cd "$PRG_HOME" && pwd`

checkFailure() {
  # $1 exit code
  # $2 message
  if [ $1 -ne 0 ] ; then
    echo "Command failed: $2"
    exit 1
  fi
}

# Once built, this will allow one to see how many changes happen with each diff.
#  Unusual large changes usually pop up this way.
# git log --stat --oneline

SUFFIX=".json.gz"

pushd $GIT_DIR
git status
# Create the empty git repository with:
#  git init --initial-branch=main
checkFailure $? "$GIT_DIR is not a git directory."
popd

for F in $(find $SRC_DIR/ -type f | sort | grep "iTunes-\d\d\d\d-\d\d-\d\d$SUFFIX") ; do
  NAME=`basename -s"$SUFFIX" $F`
  echo "Processing $NAME"

  gzip -cd $F > $GIT_DIR/itunes.json
  checkFailure $? gzip

  $PRG_HOME/database-add-git.sh $GIT_DIR $NAME
  checkFailure $? database-git
done
