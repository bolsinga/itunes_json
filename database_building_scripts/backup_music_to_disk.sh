#!/bin/sh

rsync -avzr --delete-after --exclude 'Desktop*' /Data/music/ /Volumes/Music/music_albums
