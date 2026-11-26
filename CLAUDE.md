# itunes_json

Swift package that snapshots the Music library to JSON, commits each snapshot to a git repository tagged by date, and mines that history into SQLite databases. The CLI is `tunes`. See `README.md` for usage and `docs/rfcs/` for design detail.

## Layout

- `Sources/iTunes/` is the library, and nearly all logic lives here. `Sources/iTunes/Program.swift` is the real root command (`backup` is the default subcommand). Subcommands live in `Backup*`, `Patch/`, `Repair/`, `Batch/`, `Query/`, `Archive/`.
- `Sources/tunes/Program.swift` is only an `@main` shim.
- `Tests/iTunes/` uses Swift Testing (`@Test`).
- `database_building_scripts/db.sh` is a helper script. Its commented-out queries use an older schema (see RFC 0004).

## Build and test

- `swift build`
- `swift test -v -Xswiftc -warnings-as-errors` is what CI runs, so keep the build warning-free.
- CI also builds scheme `iTunes` with `xcodebuild` for macOS and the iOS Simulator (Xcode 27), one job per destination. A separate job fails if `swift-format` changes any file or `swift-format lint --strict` reports anything. Run `xcrun swift-format format --in-place --recursive Sources Tests Package.swift` and `xcrun swift-format lint --strict --recursive Sources Tests Package.swift` before pushing. Each existing finding is marked `// swift-format-ignore: <Rule>` above its statement or declaration, to be fixed in groups. Mark a deliberate new one the same way. The shared steps live in `.github/actions/`. Code that uses `iTunesLibrary` must stay inside `#if canImport(iTunesLibrary)` so the iOS build compiles.
- `swift-tools-version:6.4`, macOS 27 / iOS 27. All dependencies are pinned with `exact:`. Dependabot proposes bumps.

## Conventions

- Strict Swift 6 concurrency. Anything crossing tasks is `Sendable`. `Database` is an `actor`. Streams use `AsyncThrowingStream.makeStream()` fed from `Task.detached`. No Combine.
- Logging: each file declares `fileprivate static let x = Logger(category:)`. Contexts carry a `loggingToken`.
- Localization is minimal. `Localizable.xcstrings` has two keys, and subcommand help strings are not localized.
- Use 2-space indentation (matches existing files).

## Things that bite

- **On-disk contract.** Git tags look like `iTunes-yyyy-MM-dd[.NN][-empty]` and are never overwritten. Commit messages are `<tag>\n<version>`. The backup writes `itunes.json` to a hardcoded `main` branch and pushes, so it needs a remote. Changing `Track` field order or pruning rewrites every future diff.
- **MusicKit is incomplete.** It is implemented but does not fully work as expected ([#405](https://github.com/bolsinga/itunes_json/issues/405)). Treat iTunesLibrary as the reliable source.
- **Daylight saving bug.** Dates in the data from Music are affected by a daylight saving bug, whichever source is used ([#328](https://github.com/bolsinga/itunes_json/issues/328)). Be careful with date comparisons.
- **Repair.** It writes a new branch, bumps the tag version (`-V<n+1>-`), never pushes, and needs a clean tree. `replace-persistent-ids` changes the join key, so it is dangerous.
- **Patch matching.** Patch and repair join on `persistentID`.
- **History walk.** `Repository.transformTracks` starts one task per tag with no cap, and its results are in no defined order (they differ from run to run), so a caller that needs an order sorts them itself. Only the highest `StructuredTag` per date is read. A tag that fails does not stop the others, and `TransformError` lists the failing tags once all have run. `query` and `batch` memory does not grow with history, but `archive` holds every flat database in memory by design (RFC 0003).
- **SQLite schema.**
  - `plays` stores Music's cumulative count (`itunesid, date, count`). There is no `delta` or `songid` column.
  - `albums.artistid INTEGER NON NULL` is a typo, so the NOT NULL is not enforced.
  - `Track(row:)` reads `count` from the flat table, but the table column is `playcount`.
  - `--lax-schema` relaxes only the four normalized tables.
  - `foreign_keys=ON` is set per connection.
- **Corrections `.db` patches.** In `CorrectionsDBRow.swift`, `year` and `duration` read `.trackNumber` and `trackcount` is always nil, so `.db` corrections are broken for those fields. The JSON path is fine.
- **Untested.** `Repository`, batch, query, archive, and the archive SQL have no tests.

## RFCs

| RFC | Topic |
|---|---|
| [0001](docs/rfcs/0001-backup-pipeline.md) | Sources, Track, git snapshots and tags, CLI, CI |
| [0002](docs/rfcs/0002-patch-and-repair.md) | Patch and repair, truth model, patch formats |
| [0003](docs/rfcs/0003-history-iteration-commands.md) | Repository, batch, query, archive, tests, roadmap |
| [0004](docs/rfcs/0004-sqlite-schema.md) | DDL, constraints, strict vs lax, SQL generation |

These describe existing behavior (as of 2026-11-25). Keep them in sync when changing the area they cover.
