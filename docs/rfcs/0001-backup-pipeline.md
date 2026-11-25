# RFC 0001: Backup Pipeline

Status: Documented (describes existing behavior)

## Summary

`tunes backup` (the default subcommand) reads the user's Music library, converts each item to a `Track`, optionally reduces and patches the list, sorts it, and writes it out as JSON, SQL code, or a SQLite database. With `--json-git` the JSON is committed to a git repository and tagged with the snapshot date. Existing tags are never overwritten. This RFC covers that path, the build and CI setup, and the permission notes from the README.

## Motivation

The git history of `itunes.json` is the long-lived record of listening history. Later commands (`patch`, `repair`, `batch`, `query`, `archive`) read that history, so the commit and tag format is a de facto on-disk contract. The same JSON feeds the web generator described in README.md. A contributor changing `Track`, tag naming, or the git flow needs to know what other code depends on them.

## Detailed design

### Targets and build (Package.swift)

- swift-tools-version 6.4. Platforms are macOS 27 and iOS 27.
- Library `iTunes` (`Sources/iTunes`) holds all logic. Executable `tunes` (`Sources/tunes/Program.swift`) is only an `@main` shim that calls `Program.main()`.
- The real root command is `Sources/iTunes/Program.swift` (`Program`, an `AsyncParsableCommand`). Its subcommands are `BackupCommand`, `PatchCommand`, `RepairCommand`, `BatchCommand`, `QueryCommand` and `ArchiveCommand`. `defaultSubcommand` is `BackupCommand`, so `tunes --json-git ...` and `tunes backup ...` are equivalent.
- Dependencies are all pinned with `exact:`: swift-argument-parser, GitLibrary (bolsinga), PackageBuildInfo (bolsinga) and swift-collections.
- `PackageBuildInfoPlugin` runs as a build plugin on `iTunes`. `Sources/iTunes/Version.swift` exposes `iTunesVersion = PackageBuild.info.version`. This version string goes into every commit message.
- A localized string catalog lives at `Sources/iTunes/Resources/Localizable.xcstrings`. It is used for the `tunes` command name and abstract.
- Tests are in `Tests/iTunes` and use Swift Testing (`import Testing`).

### CI (.github/workflows)

`main.yml` runs on push and PR to `main`. `release.yml` runs the same steps when a release is published. Both use the runner label `xcode-27` and select Xcode 27.0. The steps are:

1. `swift test -v -Xswiftc -warnings-as-errors`. Warnings fail the build.
2. `xcodebuild -skipPackagePluginValidation -scheme iTunes -destination "generic/platform=iOS Simulator" -destination "generic/platform=macOS"`.

The iOS build matters because the library must compile on iOS. That is why the iTunesLibrary code is wrapped in `#if canImport(iTunesLibrary)`.

### Data flow

```
BackupCommand.run()
  -> Source.gather(reduce:)               Source+Tracks.swift
  -> [Track].backupPatch(patchURL)        Track+Patch.swift   (only if --patch-url)
  -> Destination.emit(tracks)             Destination+Tracks.swift
       guard non-empty -> sorted() -> Destination.data(for:) -> write
```

### Sources (Source.swift, Source+Tracks.swift)

`Source` has two cases, exposed as flags through `EnumerableFlag` in `BackupCommand.swift`. The flag names are derived by ArgumentParser, so the flags are `--itunes` (default) and `--musickit`.

- **iTunesLibrary** (`Track+MediaItem.swift`) builds each Track from an `ITLibMediaItem`. It uses `ITLibrary(apiVersion: "1.1")` and `allMediaItems`, in `Track.gatherAllTracks()`. The whole file is under `#if canImport(iTunesLibrary)`. Where the framework is absent, `Source.gather()` throws a local `iTunesError.notAvailable`. Zero or unset numeric fields are omitted so they encode as absent.
- **MusicKit** (`Track+Song.swift`) calls `MusicAuthorization.request()` and prints the status. It then issues a `MusicLibrarySectionedRequest<Album, Song>` and builds Tracks from the sections. Many fields are commented out because MusicKit does not provide them. MusicKit output is therefore sparser than iTunesLibrary output.

After gathering, `Source.gather(reduce:)` does two things:

1. With `--reduce`, `Track.reducedTrack` (`Track+Reduce.swift`) drops everything that is not `isSQLEncodable` (podcasts, voice memos, TV shows, apps, books, video, and so on; `Track+SQLEncodable.swift`). It then applies `Track.pruned` (`Track+Prune.swift`), which keeps only the fields the SQL schema and history need.
2. `duplicateAndEmptyFieldsRemoved` (`Track+ReduceFields.swift`) turns empty strings into nil. It also drops `sort*` fields that merely repeat the unsorted field. This always runs, so git diffs stay small.

### Track (Track.swift and extensions)

`Track` is a flat `Codable, Hashable, Sendable` struct. Property names map to the iTunes.plist keys in trailing comments, and most are optional. Only `name` and `persistentID` are required. Dates are ISO8601 strings. `isrc` is the only non-plist field. Output order comes from `Track+Comparable.swift`. SQL-encodable (music) tracks sort first, then by artist (falling back to album artist), album, disc number and track number. A stable sort keeps JSON diffs deterministic, so changing this ordering rewrites history diffs. Other extensions cover patching (`Track+Patch.swift`), DB rows (`Track+RowSong.swift`, `Track+RowAlbum.swift`, `Track+RowPlay.swift`, `Track+DatabaseRow.swift`) and `Track+SQLEncodable.swift`.

### CLI options (BackupCommand.swift)

| Option | Meaning |
|---|---|
| `--itunes` / `--musickit` | `Source`. Default is itunes. |
| `--json` (default), `--json-git`, `--sql-code`, `--db`, `--flat` | `DestinationContext`. |
| `--reduce` | Minimal, music-only tracks. |
| `--lax-artists`, `--lax-albums`, `--lax-songs`, `--lax-plays` | `[SchemaFlag]`, mapped to the `SchemaOptions` option set (`SchemaFlag.swift`, `SchemaOptions.swift`). They apply to the normalized schema only, so `--sql-code` and `--db`. `--flat` ignores them. |
| `--output-directory <dir>` | Created (with intermediate directories) if missing. |
| `--file-name <name>` | Defaults to `iTunes-yyyy-MM-dd` (`String+DefaultName.swift`). The extension comes from the destination: `.json`, `.sql` or `.db`. |
| `--patch-url <file>` | Applies a Patch JSON to the tracks before output (`Track+Patch.swift`). |

`validate()` rules:

- `--db` and `--flat` require `--output-directory`, because they write a file.
- `--json-git` requires `--output-directory`, which is the repository.
- With no output directory, `--json` and `--sql-code` write UTF-8 to stdout.
- `--lax-*` flags with other destinations are silently ignored. The help text says "only applicable", but nothing validates it.

`Destination` (`Destination.swift`) is the internal mirror of `DestinationContext`. The cases are `.json(Output)`, `.jsonGit(GitBackupContext)`, `.sqlCode(SQLCodeContext)` and `.db(DatabaseFormat)`. `Output` (`Output.swift`) is `.file(URL)` or `.standardOut`. `DatabaseFormat` (`DatabaseFormat.swift`) is `.normalized(DatabaseContext)` or `.flat(FlatTracksDatabaseContext)`. The flat format only includes `isSQLEncodable` tracks. Files are written with `.atomic`. An in-memory DB storage throws `noMemoryDatabase` on emit. An empty track list throws `noTracks`, so a failed or unauthorized read cannot overwrite a backup or create an empty commit.

### Git backup (`--json-git`)

Files: `GitBackupContext.swift`, `Git+Backup.swift`, `Repository.swift`, `URL+BackupFile.swift`, `Backup.swift`, `String+GitNames.swift`, `TagParser.swift`, `StructuredTag.swift`. Git itself comes from the `GitLibrary` package, via `Implementation.subProcess(directory:)`. That means it shells out to the `git` binary.

`Repository.backupFile` is always `<output-directory>/itunes.json`, and `--file-name` is ignored here. The directory must already be a git repository.

Sequence (`Git.backup` in `Git+Backup.swift`):

1. `git status` to check the repo is valid. Then `checkout main`. The branch name is hardcoded.
2. Find the tag prefix with `describeTag()`, the latest tag. `GitBackupContext.tag` parses it with `TagParser.tagPrefix`. It falls back to `"iTunes"` (`GitBackupContext.defaultTag`) if there is no tag or it cannot be parsed. This lets a repo keep a custom prefix.
3. Write the JSON atomically to `itunes.json`.
4. `git add`, then `git diff`. The code treats a thrown error as "there are changes". The assumption is that GitLibrary's `diff()` throws when the staged diff is non-empty and returns when it is empty.
5. Compute the name and commit or tag it (see below).
6. `git push`, `git push --tags`, then `gc`. A remote must be configured, or the command fails after the local commit and tag already exist.

### Tag and commit format

- Base name is `<prefix>-<yyyy-MM-dd>`, from `String.defaultDestinationName` using today's date in the local timezone. Example: `iTunes-2026-11-25`.
- `String.calculateBackupName(from:)` looks at existing tags for that prefix that start with the base name. It strips `-empty` and takes the highest. If none exist it uses the base name. Otherwise it applies `nextTag`, which appends or increments a two-digit suffix: `iTunes-2026-11-25`, then `.01`, then `.02`, and so on. This is how "never overwrite existing tags" works: every run produces a new unique name.
- `Backup.noChanges` appends `-empty` (`Backup.swift`). In that case no commit is made, and the tag points at the current HEAD. Example: `iTunes-2026-11-25.01-empty`. The `-empty` suffix is ignored when computing the next number.
- `Backup.changes` creates a commit whose message is `"<tagName>\n<version>"`. The second line is the `PackageBuildInfo` version of the tool, and the commit is then tagged with `tagName`.
- `TagParser` has two regexes: `tagPrefixAndStamp` matches `<prefix>-YYYY-MM-DD[.NN]` and `tagVersion` matches `<root>-V<n>` or `<root>.V<n>`. `StructuredTag` (`root`, `version`, `stamp`) renders as `root-V<version>-<stamp>`. Ordering is by root, then version, then stamp. Its `next` bumps the version. `Tag<Item>` and the `Tagged` protocol (`Tag.swift`, `Tagged.swift`) pair a tag name with an item (for example `Tag<Data>`).
- `Git+Write+TagData.swift` is a different writer. It replays `[Tag<Data>]` onto a new branch from an initial commit, using the same `<tag>\n<version>` message and the same empty-diff handling. It tags each commit, but unlike the backup path it does not add `-empty` suffixes. It is used by the repair flow (`Repository+Read+TagData.swift` reads the stream of tags), not by `backup`. The push, tag-push and gc calls in it are commented out.

### Permissions and scheduling (README.md)

- For scheduled backups, run `tunes` as a LaunchAgent.
- Since macOS Sequoia, the process needs to be in an application bundle that has Music Library permission (the README points to bolsinga/iTunesJson). Otherwise it asks for permission on every launch.
- A bare SwiftPM executable has no Info.plist and no entitlement, so permission prompts are not persistent. This repo does not contain the app bundle.
- `--musickit` additionally prints the `MusicAuthorization` status to stdout. That text would end up in `--json` stdout output.

## Edge cases and gotchas

- Same-day reruns produce `.01`, `.02` tags. Reruns with no changes still make `-empty` tags. They do not commit.
- Tag selection depends on string prefixes. A custom prefix that is a prefix of another (for example `iTunes` and `iTunesTest`) can match the other's tags in `allMatchingTags` (`starts(with:)`).
- A failed push leaves a local commit and tag. The next run still works and picks the next name.
- Version numbers in commit messages change whenever the package is released. Tools that parse history should not rely on them.
- Existing history was produced with older tag shapes. The regexes accept `-` or `.` before the version, which is why they look loose.
- `--reduce` changes the JSON contents. Mixing reduced and unreduced backups in one repo creates noisy diffs and may confuse `patch` and `batch`.

## Open questions

- Should `main` be configurable? It is hardcoded in `Git+Backup.swift`.
- Should `--lax-*` with a non-SQL destination be a validation error?
- The MusicKit authorization message is printed to stdout and can pollute `--json` output. Should it go to stderr?
- Should `--file-name` be rejected or documented as ignored for `--json-git`?
- Should `-empty` tags exist at all, or should no-change runs skip the tag?
- Should `Git+Write+TagData.swift` share the naming logic with `Git+Backup.swift`?
- Should CI also run on non-Xcode-27 runners, or on Linux, given the `canImport` guards?

## Known issues

- **MusicKit is incomplete.** The MusicKit source is implemented but does not fully work as expected. See [#405](https://github.com/bolsinga/itunes_json/issues/405).
- **Daylight saving bug in the source data.** The dates in the data from Music have a daylight saving time bug, regardless of whether iTunesLibrary or MusicKit is the source. See [#328](https://github.com/bolsinga/itunes_json/issues/328).
