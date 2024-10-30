# itunes_json
This uses the [iTunesLibrary framework](https://developer.apple.com/documentation/ituneslibrary) or [MusicKit](https://developer.apple.com/musickit/) to emit JSON representing the music library.

It can also emit SQL code for a database. `itunes_json --itunes --sql-code | sqlite3 > /tmp/itunes.db` Right now the schema is documented only [in code](https://github.com/bolsinga/itunes_json/blob/main/Sources/iTunes/SQLSourceEncoder.swift). Then you can get information such as last playdates in order: `SELECT s.name, a.name, p.date, p.delta FROM songs s, artists a, plays p WHERE s.artistid=a.id AND p.songid=s.id ORDER by p.date;`

In Catalina, the iTunes Music Library.xml file no longer exists. My [web generator](https://github.com/bolsinga/web_generator) program relied upon this. This code uses the library to create JSON for web generator to read. 

In Sequoia, this must be run in an [application bundle with permission to use the Music Library](https://github.com/bolsinga/iTunesJson), or it will re-request Music Library permission on every launch.
