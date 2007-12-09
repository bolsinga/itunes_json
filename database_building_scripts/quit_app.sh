#!/bin/sh

# Quit app if it is running
appname=$1
app=`ps wwwaux | grep $appname\.app | grep -v grep`
if [ "$app" ]
then
/usr/bin/osascript <<EOF
tell application "$appname"
quit
end tell
EOF
sleep 10
fi
