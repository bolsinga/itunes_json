# RFC 0004: SQLite Schema and SQL Generation

Status: Documented (describes existing behavior)

## Summary

`tunes` can turn `[Track]` into SQLite in two shapes: a normalized database (tables `artists`, `albums`, `songs`, `plays`, plus helpers and two views) and a flat database (one table named `tracks`). The output is either a SQL script (`backup --sql-code`, normalized only) or a database (`--db` normalized, `--flat` flat). The schema lives only in Swift string literals; this RFC extracts it. All DDL (data definition language: the `CREATE TABLE` and `CREATE VIEW` statements that define the schema) below was checked against the sources listed per section and loaded into sqlite3 3.54.

## Motivation

README.md says the schema is "documented only in code". The README example query no longer runs (see Example queries), and `database_building_scripts/db.sh` targets an older schema. Contributors need one reference for the DDL, constraints, lax flags and known sharp edges.

## Detailed design

### Pipeline

- `Track.isSQLEncodable` (Track+SQLEncodable.swift) drops podcasts, voice memos, TV shows, apps, books, video, PDFs, iTunes LP/Extras, streams, QuickTime movies, tracks with no artist (`artist ?? albumArtist`), and remote tracks with no kind and zero time. Both formats use it.
- Normalized: `Track.trackRow` builds a `TrackRow` (RowAlbum, RowArtist, RowSong, optional RowPlay, RowAdd, RowRelease). `TrackRowEncoder` hands rows to `*TableBuilder`s (protocol `TableBuilder`: `schema(constraints:)`, `rows`, `statements`, `argumentBuilder`).
- Table order is fixed: artists, albums, songs, added, released, plays, then views (`TracksDBEncoder.encode`, `TracksSQLSourceEncoder.sqlStatements`). Both start with `PRAGMA foreign_keys = ON;`.
- Flat: `FlatDBEncoder` runs one transaction: schema, then one prepared INSERT per track. It throws `errorNoItems` for an empty list. It does not set the foreign key pragma (it has no keys).
- Format selection: `DatabaseFormat.normalized(DatabaseContext)` or `.flat( FlatTracksDatabaseContext)`; `DatabaseStorage` is `.file(URL)` or `.memory` (`":memory:"`). `batch`, `query` and `archive` use `.memory` per tag.

### SQL code vs .db file

- `--sql-code` (`TracksSQLSourceEncoder`): one text stream: the pragma, then for each table its `CREATE TABLE IF NOT EXISTS` DDL followed by its INSERT statements (literals with `'` doubled, via `Statement.description`), each table's inserts sorted as strings, then the views. There is no BEGIN/COMMIT. Foreign keys are resolved with subselects, for example `(SELECT id FROM artists WHERE name = 'X')` (`RowArtist.selectID`, `RowAlbum.selectID`).
- `--db` (`TracksDBEncoder`): inserts use bound parameters inside one transaction per table (`Database.createTable`). Foreign keys are resolved from the in-memory `[Row: Int64]` lookups returned by earlier tables (`lastID`), falling back to `-1` if the lookup misses (which then violates the foreign key). The bytes are produced with `sqlite3_serialize` (`Database.data()`).
- Connection setup (`Database.init`): `sqlite3_open_v2` with `SQLITE_OPEN_URI|READWRITE|CREATE`; `PRAGMA journal_mode = WAL`; `PRAGMA synchronous = NORMAL`. File storage uses `url.absoluteString` (a `file:` URI).
- The two paths are not byte-equivalent. `AlbumTableBuilder.statements` and `SongTableBuilder.statements` emit one INSERT per track, while `rows` (used by `--db`) de-duplicates albums via `Set`. In SQL code a repeated album therefore fails `UNIQUE` under strict (the sqlite3 CLI keeps going) and becomes a duplicate row under lax albums.

### Normalized DDL

Sources: ArtistTableBuilder, AlbumTableBuilder, SongTableBuilder, PlayTableBuilder, AddedTableBuilder, ReleasedTableBuilder. Strict form shown; lax differences follow in "Strict vs lax".

```sql
CREATE TABLE IF NOT EXISTS artists (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  sortname TEXT NOT NULL DEFAULT '',
  CHECK(length(name) > 0),
  CHECK(name != sortname)
);
CREATE TABLE IF NOT EXISTS artistids (
  itunesid TEXT NOT NULL PRIMARY KEY,
  artistid INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS albums (
  id INTEGER PRIMARY KEY,
  artistid INTEGER NON NULL,            -- sic, see pitfalls
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
);
CREATE TABLE IF NOT EXISTS albumids (
  itunesid TEXT NOT NULL PRIMARY KEY,
  albumid INTEGER NOT NULL
);
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
);
CREATE TABLE IF NOT EXISTS added (
  itunesid TEXT NOT NULL PRIMARY KEY,
  date TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS released (
  itunesid TEXT NOT NULL PRIMARY KEY,
  date TEXT NOT NULL
);
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
);
```

Notes:

- `artistids` and `albumids` are created empty by backup/batch; only the `archive` command populates them (itunesid to artist/album id mapping).
- `added` and `released` are always created strict (`TracksDBEncoder` passes `.strict`). `RowRelease.date` is nil for tracks without a release date; the `INSERT OR IGNORE` silently skips the NOT NULL violation, so `released` only has rows for tracks with a date. The `tracks` view uses `COALESCE(dr.date, '')`.
- Dates are ISO 8601 strings (`Track.dateAdded`, `playDateUTC`, `releaseDate`) stored as TEXT; lexical order equals chronological order for UTC `Z` strings.
- Booleans are integers: `compilation` is 0/1.

### Views

Defined in `TrackRowEncoder.views`, created with `IF NOT EXISTS`.

```sql
CREATE VIEW IF NOT EXISTS tracks AS
SELECT s.itunesid AS itunesid, s.name AS name, s.sortname AS sortname,
  a.name AS artist, a.sortname AS sortartist,
  al.name AS album, al.sortname AS sortalbum,
  s.tracknumber AS tracknumber, al.trackcount AS trackcount,
  al.disccount AS discount,            -- sic: one 'c' missing
  al.discnumber AS discnumber, s.year AS year, s.duration AS duration,
  da.date AS dateadded, al.compilation AS compilation, s.composer AS composer,
  COALESCE(dr.date, '') AS datereleased, s.comments AS comments,
  p.date AS playdate, p.count AS count
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

`tracks` yields one row per (song, play): a song with several plays (possible in the archive) appears several times, and a never-played song has NULL `playdate` and `count`. `Track(row:)` (Track+DatabaseRow.swift) maps these columns back to `Track`; it reads `count` and `disccount`, so from the view `discCount` is always nil (view says `discount`). `DatabaseRowLookup` treats empty strings as missing; `boolean` is true only for integer 1; a missing `name` or non-numeric `itunesid` makes the row nil.

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
);
```

`FlatTrackRow` supplies defaults instead of failing: missing strings become `''`, numbers 0, `disccount`/`discnumber` 1, `compilation` 0/1, `playcount` 0. Differences from the normalized view: the table is named `tracks` too (so a query written against `tracks` runs on both), but the play count column is `playcount` not `count`, `disccount` is spelled correctly, and a `Track` is one row (only the latest play info Music reports).

### Strict vs lax

`SchemaOptions` is an `OptionSet` built from CLI `--lax-schema` flags (`SchemaFlag`: `laxArtists`, `laxAlbums`, `laxSongs`, `laxPlays`; flags are repeatable). Empty set = strict (default); `SchemaOptions.laxSchema` = all four. Each table maps to `SchemaConstraints` (`.strict`/`.lax`). Flags apply to `backup --sql-code|--db`, `batch`, `query`, `archive`; `added`/`released` and the flat table ignore them.

| Table | Lax removes |
|-------|-------------|
| artists | `UNIQUE` on name, `CHECK(length(name) > 0)`, `CHECK(name != sortname)` |
| albums | the `UNIQUE(...)` tuple, `CHECK(length(name)>0)`, `CHECK(name != sortname)`, `CHECK(trackcount > 0)`. Keeps FK and the disccount/discnumber/compilation checks |
| songs | `tracknumber > 0`, `year >= 0`, `duration > 0`. Keeps `length(name)>0`, `name != sortname`, UNIQUE, both FKs |
| plays | `UNIQUE(itunesid,date,count)`, `UNIQUE(date)`, `CHECK(count > 0)`. Keeps the FK and `length(date)>0` |

Strict failures are mostly data placeholders: missing track number, track count, or year become `-1`, missing duration `-1`, missing album/artist name the empty `SortableName` (`name=''`). These violate the strict checks, so strict generation fails on incomplete libraries; lax lets the data load for analysis.

### Sort-name handling

`SortableName(name:sorted:)` stores `sorted` as `''` when it equals `name`, so "no special sort name" is always the empty string. This is why the schema has `sortname NOT NULL DEFAULT ''` and `CHECK(name != sortname)` (an empty sortname satisfies the check; a redundant copy does not). Artist sort name falls back `sortArtist ?? sortAlbumArtist`. Ordering (`<`) uses `sorted` if non-empty, else `name`; builders sort rows with `name` only (`$0.name < $1.name` compares the `SortableName` ordering). `artistTableBuilder` logs (`duplicateArtist`) when the same artist name appears with differing sort names; under strict that becomes a UNIQUE failure, under lax two rows share a name. `RowArtist.selectID` matches on `name` only, so SQL-code lax output can resolve to the first of duplicates. The archive SQL reconciles by filling an empty sortname from a sibling row with the same name.

### Plays and deltas

There is no `delta` column and no `songid`. `plays(itunesid, date, count)` stores Music's cumulative `playCount` and last play date per track for the snapshot. `RowPlay` exists only if `playCount > 0 || date != ''`; a count without a date (`noPlayDate`) or a date without a count (`noPlayCount`) is logged. The historic `delta` column was replaced by `count` (commit 2d038b1, "plays table tracks count for now"). Per snapshot there is one play row per played track, so `UNIQUE(date)` fails when two tracks share a last-played timestamp (`duplicatePlayDates` logs them; albums played back to back can collide).

The `archive` command accumulates snapshots (ArchiveCommand.swift): it loads each git tag into an in-memory flat DB, attaches the archive as `archive`, and runs the update SQL for artists, albums, added, released, songs, then plays. For plays it (1) repairs duplicate dates within an album by adding the earlier track's duration, (2) keeps the archived date when it differs by an exact whole-hour offset under 12 hours (time zone/DST noise), then (3) inserts only rows not equal to `archive.lastplays`. Hence `lastplays` is the "current state" per song, and deltas are derived at query time, for example with `LAG(count)` (below).

### Indexes

None besides primary keys and the implicit indexes behind UNIQUE constraints. Notable: `plays.itunesid` is only indexed through `UNIQUE(itunesid,date,count)` in strict mode; lax plays has no usable index on it, and `lastplays` and the `tracks` view join on `itunesid`.

### Example queries

The README query does not work on the current schema: `SELECT s.name, a.name, p.date, p.delta FROM songs s, artists a, plays p WHERE s.artistid=a.id AND p.songid=s.id ORDER by p.date;` fails with `no such column: p.delta` (verified; `p.songid` is also gone). Same for the queries in `database_building_scripts/db.sh` (`songid`, `delta`, `songs.id`, `tracks.sid`, `newer.tracks` with song/track columns). Working equivalent:

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

`DatabaseRowTests` covers `Track(row:)` per column; `SQLiteStatementTests` checks `Statement` interpolation (`?` in `sql`, quote-doubled `description`). No test executes the DDL, so schema regressions are untested.

## Open questions

- **`artistid INTEGER NON NULL`**: SQLite parses this as column type `INTEGER NON` with no NOT NULL (verified with `PRAGMA table_info`: notnull=0). A NULL `artistid` inserts. Fix to `NOT NULL`? Changes DDL only, but existing DBs differ.
- **`discount` view typo** breaks `Track(row:)` round trips for `disccount`; flat uses `playcount` while `Track(row:)` reads `count`, so flat rows also lose play counts. Rename (and bump consumers) or read both?
- **Foreign keys** are only enforced when the connection runs the pragma; the files produced by `--db` do not persist it (it is per connection), so later consumers insert/delete freely. `-1` fallback IDs and `songs.itunesid` FK on plays rely on this pragma being on.
- **SQL code duplicates**: should `statements` de-duplicate albums like `rows`? Should the script be wrapped in `BEGIN/COMMIT` (speed, atomicity)?
- **Indexes**: add `plays(itunesid, date)` (needed in lax), `songs(artistid)`, `songs(albumid)`, `albums(artistid)`; the archive queries and `tracks` view scan.
- **STRICT tables** (SQLite 3.37+): would reject text in INTEGER columns and make `-1` sentinels vs real validation explicit. Replace the `-1` sentinels with NULL or real validation?
- **WAL**: `journal_mode=WAL` is set for every connection including `:memory:` (no effect) and file DBs written then serialized; WAL leaves `-wal`/`-shm` files and is a poor fit for a single-file backup artifact. Use DELETE journal for `--db`?
- **`UNIQUE(date)` on plays** is global across all songs; archive plays from different songs at the same second collide. Should it be per `itunesid`?
- **Deltas**: add a `play_deltas` view (the LAG query); refresh README and db.sh.
- **Album identity**: `RowAlbum.selectID` omits the artist, so SQL-code output can attach songs to another artist's same-named album, unlike the `--db` path.

