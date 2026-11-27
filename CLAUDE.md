# itunes_json

Swift package that snapshots the Music library to JSON, commits each snapshot to a git repository tagged by date, and mines that history into SQLite databases. The CLI is `tunes`. See `README.md` for usage and `docs/rfcs/` for design detail.

## Layout

- `Sources/iTunes/` is the library, and nearly all logic lives here. `Sources/iTunes/Program.swift` is the real root command (`backup` is the default subcommand). Subcommands live in `Backup*`, `Patch/`, `Repair/`, `Batch/`, `Query/`, `Archive/`.
- `Sources/tunes/Program.swift` is only an `@main` shim.
- `Tests/iTunes/` uses Swift Testing (`@Test`).
- `iTunesJson/` is the Xcode app that wraps the package so macOS remembers the Music Library permission. Its project uses the package at the repo root as a local package (`relativePath = ..`), and `iTunesJson/iTunesJson/Program.swift` only calls `iTunes.Program.main()`.
- `database_building_scripts/db.sh` is a helper script. Its commented-out queries use an older schema (see RFC 0004).

## Build and test

- `swift build`
- The app: `xcodebuild -skipPackagePluginValidation -project iTunesJson/iTunesJson.xcodeproj -scheme iTunesJson -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO`. CI builds it in the `app` job.
- `swift test -v -Xswiftc -warnings-as-errors` is what CI runs, so keep the build warning-free.
- Before pushing, run `xcrun swift-format format --in-place --recursive Sources Tests Package.swift iTunesJson` and `xcrun swift-format lint --strict --recursive Sources Tests Package.swift iTunesJson`. CI fails on a change or a finding. Mark a deliberate lint finding with `// swift-format-ignore: <Rule>`.
- The CI jobs, the shared actions and the `iTunesLibrary` guard for the iOS build are in RFC 0001.
- `swift-tools-version:6.4`, macOS 27 / iOS 27. All dependencies are pinned with `exact:`.

## Conventions

- Strict Swift 6 concurrency. Anything crossing tasks is `Sendable`. `Database` is an `actor`. Streams use `AsyncThrowingStream.makeStream()` fed from `Task.detached`. No Combine.
- Logging: each file declares `fileprivate static let x = Logger(category:)`. Contexts carry a `loggingToken`.
- Localization is minimal. `Localizable.xcstrings` has two keys, and subcommand help strings are not localized.
- Use 2-space indentation (matches existing files).

## Before you change something

Read the RFC for the area first. Each lists what the code does, its known problems and its open questions.

- **Backup and git history ([RFC 0001](docs/rfcs/0001-backup-pipeline.md)).** The git tags and commit messages are an on-disk contract, and changing the `Track` output rewrites every future diff. The known problems with the sources (MusicKit, the daylight saving bug) are listed there.
- **Patch and repair ([RFC 0002](docs/rfcs/0002-patch-and-repair.md)).** Repair rewrites the history onto a new branch, and `replace-persistent-ids` is dangerous. Patch matching, the patch formats and known bugs are there.
- **History commands ([RFC 0003](docs/rfcs/0003-history-iteration-commands.md)).** `transformTracks` has no result order, reports failures per tag, and the memory use of each command is described. It also says what `archive` is for and where it fails. Much of this layer has no tests.
- **SQLite schema ([RFC 0004](docs/rfcs/0004-sqlite-schema.md)).** The schema has known typos and quirks. Read it before changing the schema or reading from it.

## RFCs

| RFC | Topic |
|---|---|
| [0001](docs/rfcs/0001-backup-pipeline.md) | Sources, Track, git snapshots and tags, CLI, CI |
| [0002](docs/rfcs/0002-patch-and-repair.md) | Patch and repair, truth model, patch formats |
| [0003](docs/rfcs/0003-history-iteration-commands.md) | Repository, batch, query, archive, tests, roadmap |
| [0004](docs/rfcs/0004-sqlite-schema.md) | DDL, constraints, strict vs lax, SQL generation |
| [0005](docs/rfcs/0005-derived-archive.md) | Proposal: derive the archive database from the history, without repair |

RFCs 0001 to 0004 describe existing behavior (as of 2026-11-25). RFC 0005 is a proposal. Keep them in sync when changing the area they cover.
