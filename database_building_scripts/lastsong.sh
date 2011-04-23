#!/bin/sh

python $HOME/Documents/code/git/last_played_song/lastsong.py $HOME/Music/iTunes/iTunes\ Music\ Library.xml $HOME/Sites/lastSong.json

rsync -avz $HOME/Sites/lastSong.json mink.he.net:/home/bolsinga/public_html
