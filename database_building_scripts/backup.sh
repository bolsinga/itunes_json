#!/bin/sh

BACKUP=$1
SCRATCH=$2

if [ -z $BACKUP ]
then
 echo Need to supply a backup directory.
 exit 1
fi
if [ ! -d $BACKUP ]
then
 echo $BACKUP does not exist.
 exit 1
fi

if [ -z $SCRATCH ]
then
 echo Need to supply a scratch directory.
 exit 1
fi
if [ ! -d $SCRATCH ]
then
 echo $SCRATCH does not exist.
 exit 1
fi

PRG="$0"
PROG_HOME=`dirname "$PRG"`
PROG_HOME=`cd "$PROG_HOME" && pwd`

# Quit iPhoto if it is runnnig
$PROG_HOME/quit_app.sh iPhoto

DATE=`date "+%Y-%m-%d"`

UNIQUESCRATCH=$SCRATCH/$USER/backup-$DATE
mkdir -p $UNIQUESCRATCH

# Move the iPhoto Library out of the way while backing up $HOME
IPHOTO="iPhoto Library"
mv "$HOME/Pictures/$IPHOTO" "/tmp"
hdiutil create -ov -srcfolder $HOME $UNIQUESCRATCH/backup-home-$DATE.dmg
mv "/tmp/$IPHOTO" "$HOME/Pictures/"

# Back up SVN
hdiutil create -ov -srcfolder /svn/repository $UNIQUESCRATCH/backup-svn-$DATE.dmg

# Create a dmg of all the archived files
hdiutil create -ov -srcfolder $UNIQUESCRATCH $BACKUP/backup-$DATE.dmg

# Remove the spare . files
rm $BACKUP/._*.dmg

# Clean up
rm -rf $UNIQUESCRATCH
