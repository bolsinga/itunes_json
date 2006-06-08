#!/bin/sh

usage()
{
  echo "publish src_dir dest_dir project_name version"
  echo $1
  exit 1
}

SRC_DIR=$1
if [ -z "$SRC_DIR" ] ; then
  usage "No src_dir."
fi
SRC_DIR=`cd "$SRC_DIR" && pwd`
if [ ! -d "${SRC_DIR}" ] ; then
  usage "No $SRC_DIR"
fi

DEST_DIR=$2
if [ -z "$DEST_DIR" ] ; then
  usage "No dest_dir."
fi
DEST_DIR=`cd "$DEST_DIR" && pwd`
if [ ! -d "${DEST_DIR}" ] ; then
  usage "No $DEST_DIR"
fi

PROJECT=$3
if [ -z "$PROJECT" ] ; then
  usage "No project_name."
fi

VERSION=$4
if [ -z "$VERSION" ] ; then
  usage "No version."
fi

TAR_NAME=$PROJECT-$VERSION

UNIQUE_DIR=/tmp/$TAR_NAME-`id -u`-$$

TMP_DIR=$UNIQUE_DIR/$TAR_NAME

mkdir -p $TMP_DIR
cp -r $SRC_DIR/ $TMP_DIR

echo "Creating $DEST_DIR/$TAR_NAME.tar.gz"

cd $UNIQUE_DIR ; tar czf $DEST_DIR/$TAR_NAME.tar.gz $TAR_NAME

rm -rf $UNIQUE_DIR
