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
if [ $? -ne 0 ] ; then
  # Create the empty git repository with:
  #  git init --initial-branch=main
  echo "$GIT_DIR is not a git directory."
  exit 1
fi

for F in $(find $SRC_DIR/ -type f | sort | grep "iTunes-\d\d\d\d-\d\d-\d\d$SUFFIX") ; do
  NAME=`basename -s"$SUFFIX" $F`
  echo "Processing $NAME"
  gzip -cd $F > $GIT_DIR/itunes.json
  checkFailure $? gzip
  git add -A
  checkFailure $? add
  git commit -m $NAME
  if [ $? -ne 0 ] ; then
    echo "$NAME has no changes."
  fi
  git tag $NAME
  checkFailure $? tag
done

popd
