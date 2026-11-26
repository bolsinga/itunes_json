# RFC 0004: SQLite Schema and SQL Generation

Status: Documented (describes existing behavior)

## Summary

`tunes` can turn `[Track]` into SQLite in two shapes: a normalized database (tables `artists`, `albums`, `songs`, `plays`, plus helpers and two views) and a flat database (one table named `tracks`). The output is either a SQL script (`backup --sql-code`, normalized only) or a database (`--db` normalized, `--flat` flat). The schema lives only in Swift string literals; this RFC extracts it. All DDL (data definition language: the `CREATE TABLE` and `CREATE VIEW` statements that define the schema) below was checked against the sources listed per section and loaded into sqlite3 3.54.

## Motivation

The schema lives only in Swift string literals. The README example query uses the `plays.count` column (see Example queries), and the commented-out queries in `database_building_scripts/db.sh` target an older schema. Contributors need one reference for the DDL, constraints, lax flags and known sharp edges.

## Detailed design

### Pipeline

- `Track.isSQLEncodable` (Track+SQLEncodable.swift) drops podcasts, voice memos, TV shows, apps, books, video, PDFs, iTunes LP/Extras, streams, QuickTime movies, tracks with no artist (`artist ?? albumArtist`), and remote tracks with no kind and zero time. Both formats use it.
- Normalized: `Track.trackRow` builds a `TrackRow` (RowAlbum, RowArtist, RowSong, optional RowPlay, RowAdd, RowRelease). `TrackRowEncoder` hands rows to `*TableBuilder`s (protocol `TableBuilder`: `schema(constraints:)`, `rows`, `statements`, `argumentBuilder`).
- Table order is fixed: artists, albums, songs, added, released, plays, then views (`TracksDBEncoder.encode`, `TracksSQLSourceEncoder.sqlStatements`). Both start with `PRAGMA foreign_keys = ON;`.
- Flat: `FlatDBEncoder` runs one transaction: schema, then one prepared INSERT per track. It throws `errorNoItems` for an empty list. It does not set the foreign key pragma (it has no keys).
- Format selection: `DatabaseFormat.normalized(DatabaseContext)` or `.flat( FlatTracksDatabaseContext)`; `DatabaseStorage` is `.file(URL)` or `.memory` (`":memory:"`). `batch`, `query` and `archive` use `.memory` per tag.

### SQL code vs .db file

- `--sql-code` (`TracksSQLSourceEncoder`): one text stream: the pragma, then for each table its `CREATE TABLE IF NOT EXISTS` DDL followed by its INSERT statements (literals with `'` doubled, via `Statement.description`), each table's inserts sorted as strings, then the views. There is no BEGIN/COMMIT. Foreign keys are resolved with subselects, for example `(SELECT id FROM artists WHERE name = 'X')` (`RowArtist.selectID`, `RowAlbum.selectID(artistID:)`). An album is found by its artist, name and counts.
- `--db` (`TracksDBEncoder`): inserts use bound parameters inside one transaction per table (`Database.createTable`). Foreign keys are resolved from the in-memory `[Row: Int64]` lookups returned by earlier tables (`lastID`), falling back to `-1` if the lookup misses (which then violates the foreign key). The bytes are produced with `sqlite3_serialize` (`Database.data()`).
- Connection setup (`Database.init`): `sqlite3_open_v2` with `SQLITE_OPEN_URI|READWRITE|CREATE`; `PRAGMA journal_mode = DELETE`; `PRAGMA synchronous = NORMAL`. File storage uses `url.absoluteString` (a `file:` URI). See "Journal mode and durability".
- The two paths are not byte-equivalent, but they build the same albums and songs. Both write one album row for each distinct album, and attach each song to the album of its own artist. The artist is part of an album's identity (`RowAlbum.albumArtistName` is the track's artist), so the tracks of an album all have the same artist, and a compilation with several track artists is several albums. `SQLCodeTests` loads the SQL into SQLite and compares it with the `--db` result.

### Journal mode and durability

A journal is the file SQLite uses to make a transaction all-or-nothing: if the program or the machine stops part way through a commit, SQLite uses the journal to put the database back to its last complete state. SQLite has several journal modes, chosen with `PRAGMA journal_mode` (a PRAGMA is a SQLite setting command). Every connection runs `PRAGMA journal_mode = DELETE` and `PRAGMA synchronous = NORMAL` when it is opened (`Database.init`).

`DELETE` is the classic rollback journal. Before a commit changes the database file, the old pages are copied to a temporary `-journal` file. When the commit finishes, the journal is deleted. Between transactions the database is exactly one file that holds every committed row. The other common mode, WAL (write-ahead log), does the reverse: it appends new pages to a separate `-wal` file and only copies them into the main file at a later checkpoint, and it keeps a `-shm` (shared memory index) file beside it. WAL lets readers and one writer work at the same time, and it makes many small commits fast. This project has neither need: each database is written by one connection in a few large transactions, and the result is read by tools that expect a single file. With WAL, a database that is still open (the `archive` command never closes its archive connection) leaves rows in `-wal`, and copying only the `.db` file silently drops them. The file format also records the mode in the file header, so a serialized or copied file would claim to be WAL and reopening it would create `-wal` and `-shm` files and need write access to the directory. `DELETE` avoids all of that, so a `.db` file is complete and self-contained as soon as the last commit returns.

Where each kind of storage is used:

- **File storage** is `backup --db`, `backup --flat`, `archive` and the corrections file written by `patch --database` (and the same file when `repair` reads one). The `backup` formats write into the file and then also serialize it with `sqlite3_serialize` and replace the file with those bytes, so only the file format matters, not the working journal. `archive` keeps one file open for the whole run and attaches it from each per-tag memory database. The mode is written into the file header when a connection sets it, and setting it on a file already in another mode converts that file, so a file left in WAL by another tool is returned to `DELETE` when opened here.
- **Memory storage** is `batch --db`, `batch --flat` and `query`. A `:memory:` database has no file to journal, SQLite keeps its journal in memory whatever mode is requested, and the pragma is accepted and ignored. `sqlite3_serialize` of such a database writes a normal rollback-journal file header, so the `.db` files from `batch` are single files that need no care.

`PRAGMA synchronous` sets how often SQLite forces data to the disk (an fsync) while committing. `FULL` is the default and the safest. `NORMAL` forces fewer of them. With a rollback journal, `NORMAL` leaves a small chance of a damaged file if the operating system or the power fails at exactly the wrong moment during a commit. A program crash alone is safe in every setting. It stays `NORMAL` because every database this tool writes can be rebuilt from the git history or the Music library by running the command again, so the faster setting is a reasonable trade. A database that becomes the only copy of its data should switch to `FULL`.

### Normalized DDL

Sources: ArtistTableBuilder, AlbumTableBuilder, SongTableBuilder, PlayTableBuilder, AddedTableBuilder, ReleasedTableBuilder. Strict form shown; lax differences follow in "Strict vs lax".

```sql
CREATE TABLE IF NOT EXISTS artists (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  sortname TEXT NOT NULL DEFAULT '',
  CHECK(length(name) > 0),
  CHECK(name != sortname)
) STRICT;
CREATE TABLE IF NOT EXISTS artistids (
  itunesid TEXT NOT NULL PRIMARY KEY,
  artistid INTEGER NOT NULL
) STRICT;
CREATE TABLE IF NOT EXISTS albums (
  id INTEGER PRIMARY KEY,
  artistid INTEGER NOT NULL,
  name TEXT NOT NULL,
  sortname TEXT NOT NULL DEFAULT '',
  trackcount INTEGER NOT NULL,
  disccount INTEGER NOT NULL,
  discnumber INTEGER NOT NULL,
  compilation INTEGER NOT NULL,
  FOREIGN KEY(artistid) REFERENCES artists(id),
  UNIQUE(artistid, name, trackcount, disccount, discnumber, compilation),
  CHECK(length(name) > 0),
  CHECK(name != sortname),
  CHECK(trackcount > 0),
  CHECK(disccount > 0),
  CHECK(discnumber > 0),
  CHECK(compilation = 0 OR compilation = 1)
) STRICT;
CREATE TABLE IF NOT EXISTS albumids (
  itunesid TEXT NOT NULL PRIMARY KEY,
  albumid INTEGER NOT NULL
) STRICT;
CREATE TABLE IF NOT EXISTS songs (
  itunesid TEXT NOT NULL PRIMARY KEY,   -- TEXT: persistent ID is a UInt, may exceed Int64
  name TEXT NOT NULL,
  sortname TEXT NOT NULL DEFAULT '',
  artistid INTEGER NOT NULL,
  albumid INTEGER NOT NULL,
  composer TEXT NOT NULL DEFAULT '',
  tracknumber INTEGER NOT NULL,
  year INTEGER NOT NULL,
  duration INTEGER NOT NULL,            -- milliseconds (Track.totalTime)
  comments TEXT NOT NULL DEFAULT '',
  UNIQUE(itunesid, name, sortname, artistid, albumid, composer, tracknumber, year, duration, comments),
  FOREIGN KEY(artistid) REFERENCES artists(id),
  FOREIGN KEY(albumid) REFERENCES albums(id),
  CHECK(length(name) > 0),
  CHECK(name != sortname),
  CHECK(tracknumber > 0),
  CHECK(year >= 0),
  CHECK(duration > 0)
) STRICT;
CREATE TABLE IF NOT EXISTS added (
  itunesid TEXT NOT NULL PRIMARY KEY,
  date TEXT NOT NULL
) STRICT;
CREATE TABLE IF NOT EXISTS released (
  itunesid TEXT NOT NULL PRIMARY KEY,
  date TEXT NOT NULL
) STRICT;
CREATE TABLE IF NOT EXISTS plays (
  id INTEGER PRIMARY KEY,
  itunesid TEXT NOT NULL,
  date TEXT NOT NULL,
  count INTEGER NOT NULL,
  UNIQUE(itunesid, date, count),
  UNIQUE(date),
  FOREIGN KEY(itunesid) REFERENCES songs(itunesid),
  CHECK(length(date) > 0),
  CHECK(count > 0)
) STRICT;
```

Notes:

- `artistids` and `albumids` are created empty by backup/batch; only the `archive` command populates them (itunesid to artist/album id mapping).
- `added` and `released` are always created strict (`TracksDBEncoder` passes `.strict`). `RowRelease.date` is nil for tracks without a release date; the `INSERT OR IGNORE` silently skips the NOT NULL violation, so `released` only has rows for tracks with a date. The `tracks` view uses `COALESCE(dr.date, '')`.
- Dates are ISO 8601 strings (`Track.dateAdded`, `playDateUTC`, `releaseDate`) stored as TEXT; lexical order equals chronological order for UTC `Z` strings.
- Booleans are integers: `compilation` is 0/1.

### Foreign keys

A foreign key is a column whose value must be the key of a row in another table: `albums.artistid` and `songs.artistid` refer to `artists(id)`, `songs.albumid` refers to `albums(id)`, and `plays.itunesid` refers to `songs(itunesid)`. The `FOREIGN KEY` clauses are part of the table definition, so they are in the strict and the lax forms of every table, and the lax flags do not change them.

SQLite only enforces foreign keys on a connection that has run `PRAGMA foreign_keys = ON;`. The setting is off by default and it is not stored in the database file. A file keeps the declared keys (`PRAGMA foreign_key_list(songs)` lists them), but a connection that opens the file later starts with enforcement off and can insert or delete rows that break the keys. `PRAGMA foreign_key_check;` finds the broken rows at any time, whatever the setting, so it is the way to check a file that was written elsewhere.

Where the setting is on:

- `TracksDBEncoder` and `TracksSQLSourceEncoder` run it first, so a `--db` build and a `--sql-code` script are checked while they are written. This includes the normalized forms of `query` (`--tracks` and `--raw`), which build through `TracksDBEncoder` on an in-memory connection.
- `--sql-code` finds ids with subselects such as `(SELECT id FROM artists WHERE name = 'X')`. A missing row makes the subselect `NULL`, which the `NOT NULL` columns reject, so that path fails whether or not the pragma is on. The pragma is the only check on a value that is not `NULL`.
- `--db` looks ids up in the in-memory dictionaries returned by the earlier tables and writes `-1` if a lookup misses (`artistLookup[...] ?? -1` in `AlbumTableBuilder` and `SongTableBuilder`). `-1` is not `NULL`, so only the foreign key would reject it. The fallback is a guard and cannot be reached in practice: each dictionary is built from the same tracks that the dependent table is built from, so every key is present. A normalized database built from real history has no `-1` ids and `PRAGMA foreign_key_check;` finds nothing, in both the strict and the lax schema.

Where it is off: the flat database, the corrections database and `query --flat` (they declare no keys), and the connection that `archive` writes with. `archive` creates the empty archive file with `TracksDBEncoder` (pragma on), but the rows are written by a separate in-memory flat connection that runs `ATTACH DATABASE ... AS archive` and writes the archive tables. The setting belongs to that second connection, so the archive is written unchecked. The archive statements are written to keep the keys consistent, and a check after building from real history finds nothing, but nothing enforces it.

This is deliberate. The goal is a lenient pipeline that builds on imperfect data, and the keys are there to describe the relationships and to catch a bug in the generator, not to reject the library's data. Enforcement is therefore on while the generator writes, where a violation means a program bug, and left to the consumer afterward. A consumer that wants enforcement for its own writes runs the pragma on its own connection. `ForeignKeyTests` covers that a built file has no violations in either schema, that the file does not keep the setting, and that the declared keys let `foreign_key_check` find a broken row.

### Views

Defined in `TrackRowEncoder.views`, created with `IF NOT EXISTS`.

```sql
CREATE VIEW IF NOT EXISTS tracks AS
SELECT s.itunesid AS itunesid, s.name AS name, s.sortname AS sortname,
  a.name AS artist, a.sortname AS sortartist,
  al.name AS album, al.sortname AS sortalbum,
  s.tracknumber AS tracknumber, al.trackcount AS trackcount,
  al.disccount AS disccount,
  al.discnumber AS discnumber, s.year AS year, s.duration AS duration,
  da.date AS dateadded, al.compilation AS compilation, s.composer AS composer,
  COALESCE(dr.date, '') AS datereleased, s.comments AS comments,
  p.date AS playdate, p.count AS playcount
FROM songs s
LEFT JOIN artists a ON s.artistid=a.id
LEFT JOIN albums al ON s.albumid=al.id
LEFT JOIN plays p ON s.itunesid=p.itunesid
LEFT JOIN added da ON s.itunesid=da.itunesid
LEFT JOIN released dr ON s.itunesid=dr.itunesid;

CREATE VIEW IF NOT EXISTS lastplays AS
  SELECT itunesid, date, count FROM (
    SELECT *, RANK() OVER (PARTITION BY itunesid ORDER BY date DESC) AS filter FROM plays
  ) AS foo WHERE filter = 1;
```

`tracks` yields one row per (song, play): a song with several plays (possible in the archive) appears several times, and a never-played song has NULL `playdate` and `playcount`. `Track(row:)` (Track+DatabaseRow.swift) maps these columns back to `Track`. The flat table names the same columns, so it reads either. `DatabaseRowLookup` treats empty strings as missing; `boolean` is true only for integer 1; a missing `name` or non-numeric `itunesid` makes the row nil.

### Flat DDL

`FlatTracksDatabaseContext.schema`; plain `CREATE TABLE` (no `IF NOT EXISTS`), no keys other than `id`, no UNIQUE/CHECK, no indexes:

```sql
CREATE TABLE tracks (
  id INTEGER PRIMARY KEY,
  itunesid TEXT NOT NULL, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '',
  artist TEXT NOT NULL, sortartist TEXT NOT NULL DEFAULT '',
  album TEXT NOT NULL, sortalbum TEXT NOT NULL DEFAULT '',
  tracknumber INTEGER NOT NULL, trackcount INTEGER NOT NULL,
  disccount INTEGER NOT NULL, discnumber INTEGER NOT NULL,
  year INTEGER NOT NULL, duration INTEGER NOT NULL,
  dateadded TEXT NOT NULL, compilation INTEGER NOT NULL,
  composer TEXT NOT NULL DEFAULT '', datereleased TEXT NOT NULL DEFAULT '',
  comments TEXT NOT NULL DEFAULT '',
  playdate TEXT NOT NULL, playcount INTEGER NOT NULL
) STRICT;
```

`FlatTrackRow` supplies defaults instead of failing: missing strings become `''`, numbers 0, `disccount`/`discnumber` 1, `compilation` 0/1, `playcount` 0. The table is named `tracks` too, and its columns are named like the normalized view's, so a query written against `tracks` runs on both. The difference is that a `Track` is one row here (only the latest play info Music reports), while the view has a row for each play.

### Strict vs lax

`SchemaOptions` is an `OptionSet` built from CLI `--lax-schema` flags (`SchemaFlag`: `laxArtists`, `laxAlbums`, `laxSongs`, `laxPlays`; flags are repeatable). Empty set = strict (default); `SchemaOptions.laxSchema` = all four. Each table maps to `SchemaConstraints` (`.strict`/`.lax`). Flags apply to `backup --sql-code|--db`, `batch`, `query`, `archive`; `added`/`released` and the flat table ignore them.

| Table | Lax removes |
|-------|-------------|
| artists | `UNIQUE` on name, `CHECK(length(name) > 0)`, `CHECK(name != sortname)` |
| albums | the `UNIQUE(...)` tuple, `CHECK(length(name)>0)`, `CHECK(name != sortname)`, `CHECK(trackcount > 0)`. Keeps FK and the disccount/discnumber/compilation checks |
| songs | `tracknumber > 0`, `year >= 0`, `duration > 0`. Keeps `length(name)>0`, `name != sortname`, UNIQUE, both FKs |
| plays | `UNIQUE(itunesid,date,count)`, `UNIQUE(date)`, `CHECK(count > 0)`. Keeps the FK and `length(date)>0` |

Strict failures are mostly data placeholders: missing track number, track count, or year become `-1`, missing duration `-1`, missing album/artist name the empty `SortableName` (`name=''`). These violate the strict checks, so strict generation fails on incomplete libraries; lax lets the data load for analysis.

### Column types and STRICT tables

SQLite's usual column typing is flexible. A column's declared type (`INTEGER`, `TEXT`) is only an "affinity", a preference: SQLite converts a value to the declared type when it can do so without loss, and otherwise stores the value as it is, so `'seven'` goes into an `INTEGER` column as text. A STRICT table (a table declared with `STRICT` after the closing parenthesis, available since SQLite 3.37) makes SQLite enforce the declared type instead, and rejects an insert that cannot be converted. STRICT is unrelated to the strict versus lax schema flags above: those add or remove `UNIQUE` and `CHECK` constraints, while STRICT is about the kind of value a column holds. A STRICT table accepts only the column types `INT`, `INTEGER`, `REAL`, `TEXT`, `BLOB` and `ANY`.

The normalized tables and the flat `tracks` table are STRICT. The `correct_*` tables of a patch `.db` are not, because that file is edited by hand and a row that cannot be read is already dropped without a message (RFC 0002). The author wants the created database to be consistent, so the database refuses a value of the wrong kind instead of storing it. The cost was low:

- **It is available.** The app links the macOS system SQLite (`/usr/lib/libsqlite3.dylib`, 3.54 on the macOS 27 SDK), and the package requires macOS 27 and iOS 27. A test checks `sqlite3_libversion_number()` against 3.37.
- **Every column is a supported type.** The tables declare only `INTEGER` and `TEXT`. Persistent IDs are `TEXT` because they can exceed `Int64`, and dates are ISO 8601 `TEXT`.
- **The code never stores the wrong kind, so STRICT rejects nothing it writes.** Values reach SQLite as `Database.Statement.Value`, which is only `.integer(Int64)`, `.string(String)` or `.null`, produced from Swift `Int` and `String` properties by `Statement` string interpolation. The `--db` path binds them as parameters, and the `--sql-code` path writes integers bare and strings quoted (`sourceDescription`). Foreign keys are `Int64` ids, or the `-1` fallback, which is also an integer. A test builds each kind of database from complete and incomplete tracks and checks that no column holds a value of a different kind than its declared type, and a run over four snapshots of the real history, with the lax flags, found none either. None of the open data issues blocks STRICT: they concern values (a year of `0`, a missing track count, shared play dates, duplicate persistent IDs, sort-name changes), which `CHECK` and `UNIQUE` constraints catch, and not the kind of value.
- **The missing-data placeholders are the right kind.** `-1` is an integer and a missing name is the empty string, so STRICT accepts them. The lax flags work the same with or without STRICT, since they do not touch column types.
- **The cost is on the reading side.** A database file that has a STRICT table cannot be opened by a SQLite older than 3.37, and the `--sql-code` output is meant to be piped into whatever `sqlite3` is on the reader's machine. `INSERT OR IGNORE` still skips a row that violates a constraint, STRICT or not.

### Sort-name handling

`SortableName(name:sorted:)` stores `sorted` as `''` when it equals `name`, so "no special sort name" is always the empty string. This is why the schema has `sortname NOT NULL DEFAULT ''` and `CHECK(name != sortname)` (an empty sortname satisfies the check; a redundant copy does not). Artist sort name falls back `sortArtist ?? sortAlbumArtist`. Ordering (`<`) uses `sorted` if non-empty, else `name`; builders sort rows with `name` only (`$0.name < $1.name` compares the `SortableName` ordering). `artistTableBuilder` logs (`duplicateArtist`) when the same artist name appears with differing sort names; under strict that becomes a UNIQUE failure, under lax two rows share a name. `RowArtist.selectID` matches on `name` only, so SQL-code lax output can resolve to the first of duplicates. The archive SQL reconciles by filling an empty sortname from a sibling row with the same name.

### Plays and deltas

There is no `delta` column and no `songid`. `plays(itunesid, date, count)` stores Music's cumulative `playCount` and last play date per track for the snapshot. `RowPlay` exists only if `playCount > 0 || date != ''`; a count without a date (`noPlayDate`) or a date without a count (`noPlayCount`) is logged. The historic `delta` column was replaced by `count` (commit 2d038b1, "plays table tracks count for now"). Per snapshot there is one play row per played track, so `UNIQUE(date)` fails when two tracks share a last-played timestamp (`duplicatePlayDates` logs them).

Two different tracks should never have the same last-played date, so the constraint stays, and a shared date is a data issue ([#929](https://github.com/bolsinga/itunes_json/issues/929)). In the author's history, a very small share of the play dates, about a tenth of one percent, is shared by more than one track. The backup keeps `playDateUTC` to whole seconds, because both sources format it with `.iso8601`, so milliseconds are not in the data and the matches are to the second. Most shared dates are pairs, and most are between tracks of different albums, so they are not albums played back to back. The largest groups are from two months in 2007, where dozens of tracks from dozens of albums have one date, which looks like a single event, such as a sync, setting it. Smaller groups appear in every year since, more often in recent years. A shared date is not the track's modified or added date. What sets them, and whether the dates differ below a second in the library, is not known.

The `archive` command accumulates snapshots (ArchiveCommand.swift): it loads each git tag into an in-memory flat DB, attaches the archive as `archive`, and runs the update SQL for artists, albums, added, released, songs, then plays. For plays it (1) repairs duplicate dates within an album by adding the earlier track's duration, (2) keeps the archived date when it differs by an exact whole-hour offset under 12 hours (time zone/DST noise), then (3) inserts only rows not equal to `archive.lastplays`. Hence `lastplays` is the "current state" per song, and deltas are derived at query time, for example with `LAG(count)` (below).

### Indexes

An index is a second, sorted copy of one or more columns that lets SQLite jump to matching rows instead of reading the whole table. The cost is space, and time on every insert, because the index must be kept in step with the table. The schema declares no indexes of its own. The only ones are those SQLite creates for each primary key and each `UNIQUE` constraint. That is deliberate, and it fits how the databases are used.

- **Per-tag databases are built, queried once and thrown away.** `batch`, `query` and `archive` build an in-memory database for each git tag, run their SQL, and discard it. An index only pays off when many lookups share it. A query that reads the whole library (the `tracks` view, `lastplays`, a join of `songs` to `artists`) touches every row once, so an index does not speed it up, and building the index costs about as much as the query.
- **SQLite already covers the one join that matters.** The `tracks` view joins `plays` to `songs` on `itunesid`. In strict mode the index behind `UNIQUE(itunesid, date, count)` starts with `itunesid`, so it serves that join. With lax plays, which drops that `UNIQUE`, there is no index, and SQLite builds a temporary "automatic covering index" on `plays(itunesid)` for the length of the statement (`EXPLAIN QUERY PLAN` shows `SEARCH p USING AUTOMATIC COVERING INDEX (itunesid=?)`). This is on by default and the code never turns it off (`PRAGMA automatic_index`). So lax plays pays for an index only in the queries that need one.
- **`lastplays` reads all of `plays` either way.** It numbers every row with a window function (`RANK() OVER (PARTITION BY itunesid ORDER BY date DESC)`) and keeps the first, so it has to scan the whole table. An index on `plays(itunesid, date)` lets SQLite skip some of the sorting, but the measured time did not change.
- **The archive is the one persistent database, and its work is also bulk.** `archive` compares a whole snapshot against the whole archive (`EXCEPT`, `INNER JOIN` on `itunesid`, the `lastplays` comparison). The `itunesid` columns it joins on are primary keys, so they are already indexed. The columns with no index (`songs.artistid`, `songs.albumid`, `albums.artistid`, `artistids.artistid`, `albumids.albumid`) are used by whole-table joins and `NOT IN` checks, where SQLite builds what it needs on the fly.

The candidates were measured on an archive built from real snapshots with all four lax flags (so `plays` has no `UNIQUE`), with and without `plays(itunesid, date)`, `songs(artistid)`, `songs(albumid)` and `albums(artistid)`. Queries over the whole library were no faster, and some were slightly slower. Queries that look up one artist, album or song went from about a millisecond to microseconds, and `EXPLAIN QUERY PLAN` changed from `SCAN` to `SEARCH` as expected, but both are far below anything noticeable on a library this size. Creating the four indexes took about as long as one whole-library query, and made the database file roughly a fifth larger. Someone who runs many point lookups against a saved archive can add them in their own `sqlite3` session:

```sql
CREATE INDEX plays_itunesid_date ON plays(itunesid, date);
CREATE INDEX songs_artistid ON songs(artistid);
CREATE INDEX songs_albumid ON songs(albumid);
CREATE INDEX albums_artistid ON albums(artistid);
```

The flat table has no indexes either, for the same reason: it is read whole.

Indexes on the child columns of a foreign key also speed up deletes. With `PRAGMA foreign_keys = ON`, deleting an artist or album makes SQLite look for songs or albums that still point at it, and without an index on the child column that lookup is a scan. `tunes` deletes only albums that no `albumids` row refers to (in `archive`), so this does not matter today. If a command ever deletes parent rows in bulk, that is the time to index the child columns.

### Example queries

An older schema had `plays.songid` and `plays.delta` columns. Queries that use them, such as the commented-out ones in `database_building_scripts/db.sh` (`songid`, `delta`, `songs.id`, `tracks.sid`, `newer.tracks` with song/track columns), fail with errors like `no such column: p.delta`. A query that lists plays in order, like the one in the README, is:

```sql
SELECT s.name AS song, a.name AS artist, p.date, p.count
FROM songs s JOIN artists a ON s.artistid = a.id
JOIN plays p ON p.itunesid = s.itunesid ORDER BY p.date;
```

Per-play delta in an archive (verified):

```sql
SELECT s.name, a.name AS artist, p.date,
  p.count - COALESCE(LAG(p.count) OVER (PARTITION BY p.itunesid ORDER BY p.date), 0) AS delta
FROM plays p JOIN songs s ON s.itunesid = p.itunesid
JOIN artists a ON a.id = s.artistid ORDER BY p.date;
```

Usage: `tunes backup --sql-code | sqlite3 /tmp/itunes.db`; `tunes query --raw|--tracks|--flat '<sql>'` (a flag group) runs per git tag against an in-memory DB.

### Tests

`DatabaseRowTests` covers `Track(row:)` per column; `SQLiteStatementTests` checks `Statement` interpolation (`?` in `sql`, quote-doubled `description`). `ColumnTypesTests` builds each kind of database and checks that every column is `INTEGER` or `TEXT` and holds only that kind of value, and that a STRICT table behaves as described. `AlbumsSchemaTests` and `SQLCodeTests` also execute parts of the DDL, but most constraints are untested.

## Open questions

- **SQL code transaction**: should the script be wrapped in `BEGIN/COMMIT` (speed, atomicity)?
- **Sentinels**: should the `-1` placeholders for missing track numbers, track counts, years and durations become NULL, or be replaced by real validation?
- **Shared play dates:** `UNIQUE(date)` is global across all songs, so it rejects a snapshot where two tracks share a date. It stays, because the shared dates are a data issue ([#929](https://github.com/bolsinga/itunes_json/issues/929)). Should the history be corrected, and should the backup keep fractional seconds?
- **Deltas**: add a `play_deltas` view (the LAG query).

