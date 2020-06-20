#!/bin/sh

$HOME/Applications/web_generator/site $HOME/Documents/code/git/web_data $HOME/Sites site
rsync -avzr $HOME/Sites/* mink.he.net:/home/bolsinga/public_html
