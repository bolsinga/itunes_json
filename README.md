# itunes_json
This uses the [iTunesLibrary framework](https://developer.apple.com/documentation/ituneslibrary) or [MusicKit](https://developer.apple.com/musickit/) to create JSON representing your music library. This JSON contains every field possible, with compatibility with the iTunes.plist file that used to be created before macOS Catalina.

It can backup to a file or commit to a git repository for listening history. The files will be committed to git with a tag indicating the snapshot date (as well as a version). It will not write over existing tags.

It can also emit SQL (normalized only) or a SQLite3 database (normalized or flat). `tunes backup --sql-code | sqlite3 > /tmp/itunes.db` Right now the schema is documented only in code. Then you can get information such as last playdates in order: `SELECT s.name, a.name, p.date, p.delta FROM songs s, artists a, plays p WHERE s.artistid=a.id AND p.songid=s.id ORDER by p.date;`
The normalized schema is strict by default. In order to allow work to be done while the data may be incomplete, there are options to create the tables with lax schema constraints.

To have a regular backup schedule, run this as a LaunchAgent. In macOS Sequoia, it must be run in an [application bundle with permission to use the Music Library](https://github.com/bolsinga/iTunesJson), or it will re-request Music Library permission on every launch.

The json output of this program is also used as input to [web generator](https://github.com/bolsinga/web_generator), which creates [www.bolsinga.com](https://www.bolsinga.com)

## Other Modes

These modes are useful when there is listening history in a git repository created by this program. It allows the data to be mined, create patches, and repair the data. Iterations over the data will allow it to populate the database tables with strict schema enabled.

There are two database formats.
- Normalized: It has four tables: artists, albums, songs, plays. They each reference each other via IDs. The intent is that an artist only appears once, etc.
- Flat: It has a single table, which is all the tracks that are SQL encodable (aka music tracks), with the columns non unique. This will be useful for more data mining.

### patch
This will create patch files for the repair tool to use. It makes the assumption that the current data found in the Music application is correct. It then will go through the backups in git history to find "patches" to tracks that are "similar".

- `artists` - Similar artist names, including sort names.
- `albums` - Similar album names, including sort names.
- `missing-title-albums` - **Missing** album names using songs and artists.
- `missing-track-counts` - Track counts for albums that are **missing** track counts.
- `missing-track-numbers` - Track numbers for songs that are **missing** track numbers.
- `missing-years` - Years for songs that are **missing** years.
- `songs` - Song names based upon artist, album, and Music "persistentID".
- `replace-track-counts` - Replace track counts for albums.
- `replace-disc-counts` - Replace disc counts for albums.
- `replace-disc-numbers` - Replace disc numbers for albums.
- `replace-durations` - Replace track durations.
- `replace-persistent-ids` - Replace track persistent IDs. This should be used with caution.
- `replace-date-addeds` - Replace date added for a track.

### repair
This will repair a git repository with listening history, given a file created with the patch tool. It has all the same options as the patch tool, found above. It has one additional option, listed below.

- `track-corrections` - This will fix items in a hand built patch file. Please see the code for the format. These were necessary for songs that are no longer in the library, or those that needed to be repaired, but have nothing "similar" enough to automate the creation of a patch file.

### batch
This will iterate through a git repository with listening history and either create a directory full of sql code or a database file (normalized or flat) for each tag found in the repository. This is used to find bad data as the schema is made more strict.

### query
This will iterate through a git repository with listening history and execute the given SQL code on each individual database. This is useful to help determine next steps with this code and data.

- `raw` - This is the default, where the normalized database rows are just written to standard out.
- `tracks` - This will attempt to transform the query result from the normalized database `tracks` view into `[Track]`. It will just emit these tracks as JSON.
- `flat` - This will query the flat databases, written to standard out.

## Future
Back up to a single already existing database file, instead of many snapshots of data. Music will only tell you the last time a song was played. This database will have all the times it was played. I have backup data dating to 01/01/2006 to work with.
