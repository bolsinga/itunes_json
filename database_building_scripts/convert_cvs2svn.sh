#!/bin/sh

CVS_PATH=$1
PROJECT=$2

if [ -z $CVS_PATH ]
then
 echo Need to supply a cvs repository path.
 exit 1
fi
if [ -z $PROJECT ]
then
 echo Need to supply a project name for the svn repository.
 exit 1
fi

CVS2SVN=/Data/Applications/development/cvs2svn-1.3.0/cvs2svn

SVN_REPOS=/svn/repository
CVS_REPOS=/cvs/repository

TMP_DIR=`pwd`
TMP_DIR=$TMP_DIR/$PROJECT

TMP_CVS=$TMP_DIR/tmpcvs

# Create a 'fake' cvs repository that only has the project we are interested in
echo "Copying $CVS_REPOS/$CVS_PATH into $TMP_CVS..."
mkdir -p $TMP_CVS/CVSROOT
cp -r $CVS_REPOS/$CVS_PATH/ $TMP_CVS/

cd $TMP_DIR

# Use cvs2svn to make a dump file of the 'fake' cvs repository.
$CVS2SVN --dump-only $TMP_CVS

IMPORT_SH=$TMP_DIR/import_$PROJECT.sh
echo "Creating $IMPORT_SH to be run after editing the dump filter in $TMP_DIR."
cat > $IMPORT_SH <<EOF
#!/bin/sh

DUMP_FILE=\$1

if [ -z \$DUMP_FILE ]
then
    echo "svn dump file not supplied; assuming $TMP_DIR/cvs2svn-dump."
    DUMP_FILE=$TMP_DIR/cvs2svn-dump
fi

# Set up a directory in svn for this project and import it
svn mkdir file://$SVN_REPOS/$PROJECT -m "Add $PROJECT project directory."
echo "Importing $PROJECT from $TMP_CVS into $SVN_REPOST/$PROJECT"
svnadmin --parent-dir $PROJECT load $SVN_REPOS < \$DUMP_FILE
EOF
chmod +x $IMPORT_SH
