#!/bin/sh

BACKUPDIR=$1

if [ -z $BACKUPDIR ]
then
 echo Need to supply a backup directory.
 exit 1
fi

MDATE=`date "+%Y-%m-%d"`

/usr/local/mysql/bin/mysqldump -u root -p --no-create-db --no-create-info --databases diary music > $BACKUPDIR/site-backup-$MDATE.sql
