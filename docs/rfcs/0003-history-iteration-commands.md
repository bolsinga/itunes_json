# RFC 0003: History Iteration Commands and the Repository Layer

Status: Documented (describes existing behavior)

## Summary

`batch`, `query` and `archive` (plus the history-gathering half of `patch` and `repair`) share one mechanism. They read the JSON backup (`itunes.json`) from every tag of a git repository. They decode each one into `[Track]`, then do something with it. The shared mechanism is the `Repository` struct and its extensions. This RFC covers that layer, the three commands, the concurrency model, logging and localization conventions, and the tests. It also records why the README's "Future" goal (one persistent archive with every play time) is not met yet.

## Motivation

`backup` writes one snapshot per run, committed and tagged in git. Music only reports the last play date of a song, so the history is the only record of earlier plays. The iteration commands let the author:

- rebuild SQL or SQLite databases for every historical snapshot (`batch`)
- run ad hoc SQL across all snapshots (`query`)
- fold all snapshots into one database (`archive`)

These commands find bad data as the schema gets stricter (README, "batch"). Contributors need to know how the layer is structured before changing it.

## Detailed design

### Repository layer

`Repository` (`Sources/iTunes/Repository.swift`) holds a directory URL and a `git: any Git` from the `GitLibrary` package. It is created with `Implementation.subProcess(directory:suppressStandardErr: true)`, so it shells out to `git`. `backupFile` is the JSON file name inside the directory (`URL+BackupFile.swift`).

`RepositoryArguments` (`RepositoryArguments.swift`) is a shared `ParsableArguments` group. Every command adds it with `@OptionGroup`. Its `--repository` option takes a path. The transform creates the directory if it is missing, then builds the `Repository`.

### Walking git tags

`Repository.tagDatum()` (`Repository+Read+TagData.swift`) returns `AsyncThrowingStream<Tag<Data>, Error>`. Inside a `Task.detached` it does the following:

1. It calls `git.status()`, which throws if the path is not a usable repository.
2. It calls `git.tags().stampOrderedMatching`.
3. For each tag, it yields `Tag(tag:, item: git.show(commit: tag, path: backupFile.filename))`. This is the raw JSON bytes of the file at that tag.

A file-private `limit = Int.max` caps the tag count. It is effectively a debugging hook with no CLI flag.

`stampOrderedMatching` (`Array+TagFilter.swift`) first parses each tag name with `TagParser` into a `StructuredTag` (`root`, `version`, `stamp`, for example `iTunes-V12-2025-01-01`). Names that do not parse are dropped. Tags are grouped by `stamp` (the date part). For each date only the highest `StructuredTag` is kept. That is the highest root, then version, then stamp, as defined by `StructuredTag.<`. The result is sorted. So if a repair run has added `V13` for a date that also has `V12`, only `V13` is read. This is how `repair` rewrites history without duplicating snapshots.

`Tag<Item: Sendable>` (`Tag.swift`) pairs a tag name with a payload. It conforms to `Tagged` (`Tagged.swift`). `Array+Tagged.swift` gives `initialTag`, the lexicographically smallest tag.

### Fan-out: `transformTracks`

`Repository.transformTracks(transform:)` (`Repository+Tracks.swift`) is the core primitive. Inside a detached task it iterates `tagDatum()`. For each tag it adds a child task to a throwing task group. That task decodes the data with `Track.array(from:)` (`Decodable+Array.swift`) and calls the `@Sendable` async `transform(tag, tracks)`. Results are yielded to an `AsyncThrowingStream<Tag<T>>`.

All tags are therefore processed concurrently. The results are in no defined order. A result arrives when its tag finishes, so the order can differ from run to run, and it is not tag order. `transformTracks` makes no promise about it, and says so in its documentation. A consumer that needs an order sorts the results itself, as `archive`, `patch` and `query` do for tag order. The history is not normalized, so a tag can fail on its own: a snapshot may not decode, or the transform may reject its data. A failure in one tag does not stop the others. Each task catches its error and returns it. When every tag has run, the stream throws a `TransformError` that lists each tag that failed (the first ten in full, then a count) and its error. The results of the other tags have already been yielded, so `batch` writes every file it can and then exits with an error. Commands that collect all the results (`archive`, `patch`, `repair`, `query`) fail, instead of working from a history with snapshots missing. An error from reading the repository, as opposed to transforming a tag, stops the stream at once. The `defer { continuation.finish() }` is a safety net.

### CPU and memory behavior

Observed by running the commands on the author's full history: about two decades of snapshots, tens of thousands of tags, and snapshots of roughly 13 MB each. These are trends from one machine, not guarantees.

- **CPU.** There is no cap in the code, and none is needed for CPU. Swift's cooperative thread pool is sized to the machine's CPU count, so only about that many tasks run at once, however many are queued. A run keeps most cores busy and follows the hardware on its own. A hand-picked limit would not. If a limit is ever added, it should come from `ProcessInfo.processInfo.activeProcessorCount`.
- **Reading.** `tagDatum()` reads one tag at a time (one `git` subprocess at a time) into an unbounded stream, and the tasks decode and transform in parallel. Nothing makes the reader wait for the tasks.
- **`query` and `batch`.** Peak memory is a small multiple of one snapshot and does not grow with the number of snapshots. Decoding and transforming keep up with the reads, so no backlog of raw data builds up. A normalized database or SQL costs more memory than a flat database. The tags that are read are all processed in parallel, and the results are written or printed as they arrive.
- **`archive`.** Memory grows with the length of the history. It builds a flat in-memory database for every tag and collects all of them before applying any, because it needs them in tag order (see `archive` above). This is by design, and is acceptable because `archive` is the one-time transformation of the git history into the SQLite database. The nightly backup does not read the history.
- **Consumers.** Only `batch` handles results as they arrive, writing a file for each one. `archive`, `patch`, `repair` and `query` collect every result and sort them by tag first, so holding them all is part of their design. If `batch`'s writes were slower than the producers, finished results would queue in the unbounded result stream. Limiting the number of tasks would not prevent that, because a finished task leaves the group at once. The producers would have to wait for the consumer. In practice `batch`'s writes kept up, even when it wrote a large amount of SQL, so no wait is needed.

`Repository.databases(_ format:)` (`Repository+Databases.swift`) builds on this. Each tag becomes an open in-memory `Database` for the given `DatabaseFormat` (normalized or flat). The logging token is suffixed with the tag name so log lines can be told apart.

`rows(query:format:)` picks one of two strategies using `format.serializeDatabaseQueries`:

- **Parallel** (`databaseQueryRows`) executes the query on each database as it arrives.
- **Serialized** (`serializedDatabaseQueryRows`) first collects every database, sorts by tag, then runs the queries one at a time. It is needed when the SQL does `ATTACH` on a single shared file.

Both run the query with the tag bound as the first positional argument (`[.string(tag)]`). A query may use `?` to refer to the tag. Each database is closed after its query runs (`executeAndClose`). `transformRows` drops tags whose result set is empty, then applies a `@Sendable` transform.

### `batch`

`Batch/BatchCommand.swift`, `Batch/Batch.swift`.

- `--sql` (default), `--db` and `--flat` are an `EnumerableFlag` over `Batch`.
- `--lax-schema` flags go through `SchemaFlag` into `SchemaOptions`.
- `--output-directory` is created if it is missing.

`Batch.build` calls `transformTracks`. For each tag it builds a `Destination` (`sqlCode`, `db(.normalized)`, or `db(.flat)`), always in-memory storage with logging token `batch-<tag>`. It asks the destination for `Data` and writes `<tag>.sql` or `<tag>.db` into the output directory. For `.sql` the context's output is `.standardOut` as written, but the bytes are still returned and written per tag. Writing happens serially in the consuming `for try await` loop.

On the author's full history, `--db` (normalized) cannot build a database for the many snapshots in which two library entries share one `persistentID`, because `songs` is keyed by `itunesid`. They are the middle years. `batch` writes the databases it can and then fails with a `TransformError` that lists the tags that failed. `--flat` has no key, so it is not affected, and `--sql` writes the SQL, which fails when it is loaded into SQLite. `query --raw` also uses the normalized path, so it fails the same way. The normalized database does not accept such entries, by design. They are a data issue in the history ([#924](https://github.com/bolsinga/itunes_json/issues/924)).

### `query`

`Query/QueryCommand.swift`. The positional SQL argument is required (`validate()` throws `ValidationError` on an empty string). The `Transform` flag controls output:

| Flag | Database | Output |
|---|---|---|
| `--raw` (default) | normalized | `tag|col|col...` lines. The first line per tag is the column-name header. Lines are sorted by tag. |
| `--tracks` | normalized | Rows from the `tracks` view are turned into `Track` through `Track(row:)`. The command then de-duplicates (below) and prints the tag followed by pretty JSON. |
| `--flat` | flat | Same row format as `raw`, but against the flat database. |

`uniqueTracks` (`Repository+TracksQuery.swift`) sorts the per-tag results by tag. For each distinct `Track` it records the tags it appears in. Each track is then attributed only to the first tag it appears in. So `--tracks` shows when each track first appeared in the history that matched the query. That is useful for finding when bad data entered.

`--serialize-database-queries` selects the serialized path above. `--lax-schema` relaxes the normalized schema so incomplete historical data can still load.

### `archive`

`Archive/ArchiveCommand.swift`. Options are `--clear`, `--lax-schema`, `--output-directory`, `--file-name` (default `itunes`) and the repository.

1. If `--clear` is given, it deletes `<dir>/<file-name>.db`.
2. It opens or creates the normalized database file with `format.database(tracks: [])`.
3. It builds a flat in-memory database for every tag with `repository.databases(.flat(...))`. The results are collected and sorted by tag, oldest first.
4. For each one, `Database.archive(into:)` runs `ATTACH DATABASE '<path>' AS archive`. It turns on `PRAGMA foreign_keys` for that connection, so the archive tables are checked as they are written, and then runs six transactions of raw SQL, each in its own transaction: `updateArtists`, `updateAlbums`, `updateAdded`, `updateReleased`, `updateSongs`, `updatePlays`. After the last snapshot, `PRAGMA foreign_key_check` on the archive must find nothing, or `archive` fails.

The SQL is in private string constants at the top of the file. It tracks entities by `itunesid` (the persistent ID). It keeps `artistids` and `albumids` mapping tables so that renamed artists or albums keep one row. It uses `EXCEPT` against the archive to insert only new or changed data. `updatePlays` adds a row to `archive.plays` only when the (itunesid, date, count) differs from `archive.lastplays`. It also contains two heuristics:

- For tracks on one album with the same play date, it offsets the timestamp by the earlier track's duration. Most shared play dates are between tracks of different albums, which this does not cover ([#929](https://github.com/bolsinga/itunes_json/issues/929)).
- For tracks whose date moves by a whole number of hours (less than 12), it keeps the old date. This corrects the time-zone/DST quirk that `Date+Quirk.swift` also handles.

### The "Future" goal and its limits

The README's Future goal: back up into a single existing database instead of many snapshots. That database would hold every play time. History reaches back to 2006-01-01. `archive` is the one-time transformation of the git history into the SQLite database. The nightly backup does not repeat that transformation. Current limitations:

- It is not wired into `backup`, and there is no incremental path for adding only the newest snapshot to the archive.
- The history needs the lax flags and still does not archive completely (see the failure described below).
- The archive SQL is long, hard to review, and has no unit tests. It is rebuilt from history on each run rather than adding the latest snapshot incrementally. (The SQL itself can be re-run, because of the `EXCEPT` guards.)
- All flat snapshot databases are held open in memory at once, then sorted. This costs memory in proportion to history length, which is acceptable for a one-time run.
- On the author's full history, `archive` does not finish, even with every `--lax-schema` flag. Each flat snapshot database is built first, and a snapshot with a track that lacks a track number, track count, year or duration fails (`MissingValuesError`, RFC 0004): tracks with year 0 from 2014-12-01 ([#935](https://github.com/bolsinga/itunes_json/issues/935)) and tracks with no track count from 2026-09-02 ([#936](https://github.com/bolsinga/itunes_json/issues/936)). Behind those, the archive SQL stops with `UNIQUE constraint failed: artistids.itunesid`: an artist's sort name is set on some tracks before others, and the rename in `updateArtists` lands on an artist row that already exists. The `artistids` and `albumids` mapping tables have no lax form ([#921](https://github.com/bolsinga/itunes_json/issues/921)). The snapshots that have two entries with one `persistentID` ([#924](https://github.com/bolsinga/itunes_json/issues/924)) also fail the normalized build.
- Duplicate-date and DST handling is heuristic. Data problems in the history (the README says "needs some work to properly fix some issues") would produce wrong plays rows.
- The `archive` path argument is interpolated into the `ATTACH` SQL string without escaping. A path containing a single quote would break it.

### Concurrency model

- Swift 6 language mode (`swift-tools-version:6.4`, `Package.swift`). Values crossing tasks are `Sendable`: `Track`, `Play`, `Tag<Item: Sendable>`, row structs and `TableBuilder`.
- `Database` is an `actor` (`Database.swift`). It wraps SQLite3. All calls to it are `await`ed except where noted.
- `Repository` is a plain struct. The `git` property is `any Git` from `GitLibrary`.
- Streams are produced with `AsyncThrowingStream.makeStream()` and filled by `Task.detached`. Generic callbacks are `@escaping @Sendable`.
- `transformTracks` gives per-tag parallelism using a throwing task group, with no concurrency cap. The runtime's thread pool limits how many tasks run at once (see "CPU and memory behavior").
- Commands conform to `AsyncParsableCommand`. `run()` is `async throws`.

### Logging

`Logger+Category.swift` adds `Logger(category:)`, which uses `Bundle.module.bundleIdentifier` as the subsystem. Each file declares its own `fileprivate static let` logger, such as `.batch`, `.query`, `.archive`, `.transform` and `.tagStream`. `Logger+Token.swift` is an alternative initializer that puts a token in the subsystem. Contexts carry a `loggingToken` such as `batch-<tag>`, which `append(tag:)` extends for per-tag logs. Messages are `info` level.

### Localization

`Resources/Localizable.xcstrings` is processed as a package resource (`Package.swift`, `defaultLocalization: "en"`). It currently has two keys, the command name `tunes` and the top-level abstract. `Program.swift` reads them with `String(localized:bundle: .module)`. Subcommand `abstract` and `help` strings (batch, query, archive and others) are plain Swift literals and not localized.

### Support extensions

- `Array+Codable.swift`: `jsonData()` encodes with `.prettyPrinted` and `.sortedKeys`. The output is stable so it works in git.
- `Decodable+Array.swift`: `Self.array(from:)` for a URL (memory-mapped), `Data` or `String`.

### Tests

`Tests/iTunes` uses Swift Testing (`@Test`) against target `iTunesTests`. The suite covers `Tag`, `StructuredTag`, `TagListExtraction` (the tag filter), git name and string helpers (`StringGitName`, `StringPruning`), `GitBackupName`, `Play`, `TransformError`, `SQLiteStatement` and `DatabaseRow`, plus the database layer (schema, SQL code, strict tables, missing values, foreign keys, journal mode and the corrections file). `ArchiveForeignKeysTests` runs `Database.archive` on a one-track database. Run them with `swift test`.

Not covered:

- `Repository`, `transformTracks`, `databases` and the query transforms. They need a real git repository.
- `Batch`, `QueryCommand` and `ArchiveCommand`.
- The archive SQL beyond that one track, so renames, duplicate dates and the play heuristics are untested.

## Open questions

1. After the one-time `archive` run, how should the nightly backup add only the newest snapshot to the archive? The README's Future goal says it should.
2. What data fixes would let `archive` run on the full history without `--lax-schema`? The open Data issues (#921, #924, #929, #935, #936) are the blockers.
3. Does `transformTracks` need a bound? CPU use does not need one. A bound on results waiting for a consumer is only needed if `batch`'s writes ever fall behind its producers. There is also a `limit` constant in `tagDatum` that could become a `--limit` option.
4. Should the archive SQL be tested against fixture snapshots? The `Repository` layer could be made testable by taking a `Git` stub.
5. Should subcommand help strings move into `Localizable.xcstrings`?
6. Should the `ATTACH` path be bound or escaped?
