# itunes_json
This uses [iTunesLibrary framework](https://developer.apple.com/documentation/ituneslibrary) or [MusicKit](https://developer.apple.com/musickit/) to create JSON representing your music library.

It can backup to a file or a git repository contain the json file.

It can also emit SQL or a SQLite3 database. `tunes backup --sql-code | sqlite3 > /tmp/itunes.db` Right now the schema is documented only in code. Then you can get information such as last playdates in order: `SELECT s.name, a.name, p.date, p.delta FROM songs s, artists a, plays p WHERE s.artistid=a.id AND p.songid=s.id ORDER by p.date;` LAX

To have a regular backup schedule, run this as a LaunchAgent. In macOS Sequoia, it must be run in an [application bundle with permission to use the Music Library](https://github.com/bolsinga/iTunesJson), or it will re-request Music Library permission on every launch.

The output of this program is also used as input to [web generator](https://github.com/bolsinga/web_generator), which creates [www.bolsinga.com](https://www.bolsinga.com)

## Other Modes

### patch
- artists
- albums
- missing-title-albums
- track-counts
- track-numbers
- years
- songs

### repair
- track-corrections

### batch

### query
