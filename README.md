# itunes_json
This uses [iTunesLibrary framework](https://developer.apple.com/documentation/ituneslibrary) or [MusicKit](https://developer.apple.com/musickit/) to create JSON representing your music library.

It can backup to a file or commit to a git repository for listening history. The files will be committed to git with tag indicating the date snapshot (as well as a version). It will not write over existing tags.

It can also emit SQL or a SQLite3 database. `tunes backup --sql-code | sqlite3 > /tmp/itunes.db` Right now the schema is documented only in code. Then you can get information such as last playdates in order: `SELECT s.name, a.name, p.date, p.delta FROM songs s, artists a, plays p WHERE s.artistid=a.id AND p.songid=s.id ORDER by p.date;` 
The schema is strict by default. In order to allow work to be done while the data may be incomplete, there are options to create the tables with lax schema constraints.

To have a regular backup schedule, run this as a LaunchAgent. In macOS Sequoia, it must be run in an [application bundle with permission to use the Music Library](https://github.com/bolsinga/iTunesJson), or it will re-request Music Library permission on every launch.

The output of this program is also used as input to [web generator](https://github.com/bolsinga/web_generator), which creates [www.bolsinga.com](https://www.bolsinga.com)

## Other Modes

These modes are useful when there is listening history in a git repository. It allows the data to be mined, in order to make patches, and then apply the patches for repairs. Iterations over the data will allow it to populate the database tables with strict schema enabled.

### patch
This will create patch files for the repair tool to use. It makes the assumption that the current data found in the Music application is correct. It then will go through the backups in git history to find "patches" to tracks that are "similar".

- artists - Fixes similar artist names, including sort names.
- albums - Fixes similar album names, including sort names.
- missing-title-albums - Gets album names using songs and artists.
- track-counts - Gets track counts for albums.
- track-numbers - Gets track numbers for songs.
- years - Gets years for songs.
- songs - Fixes song names based upon artist, album, and Music "persistentID".

### repair
This will repair a git repository with listening history, given a file created with the patch tool. It has all the same options as the patch tool, found above. It has one additional option, listed below.

- track-corrections - This will fix items in a hand built patch file. Please see the code for the format. These were necessary for songs that are no longer in the library, or those that needed to be repaired, but have nothing "similar" enough to automate the creation of a patch file.

### batch
This will iterate through a git repository with listening history and either create a directory full of sql code or a database file for each tag found in the repository. This is used to find bad data as the schema is made more strict.

### query
This will iterate through a git repository with listening history and execute the given SQL code on each individual databases. This is useful to help determine next steps with this code.

## Future
Back up to a single already existing database file, instead of many snapshots of data. Music will only tell you the last time a song was played. This database will have all the times it was played.
