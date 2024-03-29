#/bin/sh

GIT_DIR="$1"
if [ -z "$GIT_DIR" ] ; then
    echo "No git directory" 1>&2
    exit 1
fi

MESSAGE="$2"
if [ -z "$MESSAGE" ] ; then
    echo "No message" 1>&2
    exit 1
fi

checkFailure() {
  # $1 exit code
  # $2 message
  if [ $1 -ne 0 ] ; then
    echo "Command failed: $2"
    exit $1
  fi
}

pushd $GIT_DIR

git add itunes.json
checkFailure $? add
git commit -m $MESSAGE
if [ $? -ne 0 ] ; then
  echo "$MESSAGE has no changes."
  git tag $MESSAGE-empty
else
  git tag $MESSAGE
fi
checkFailure $? tag

popd
