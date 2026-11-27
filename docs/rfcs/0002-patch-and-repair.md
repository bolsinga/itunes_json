# RFC 0002: Patch and Repair

Status: Documented (describes existing behavior)

## Summary

`tunes patch` compares tracks in the git backup history against the current Music library (or against each other) and emits a *patch file*: a list of per-track corrections keyed by persistent ID. `tunes repair` reads a patch file and rewrites the backup history onto a new branch, re-creating every tag with a bumped version. Patching never modifies the original branch.

## Motivation

The backup repository holds one `itunes.json` snapshot per tag. Over years, metadata was fixed in Music.app (titles, album names, track counts) and some fields were wrong or unstable at capture time (durations, dates). Strict SQL schemas (`batch`, `archive`) reject the stale data. Patch/repair fixes the history so every snapshot agrees. The code describes itself as a stopgap ("Repairs ... will be sunset", Sources/iTunes/Play.swift).

## Detailed design

### Pipeline

1. `PatchCommand` (Sources/iTunes/Patch/PatchCommand.swift) picks a `Repairable` flag, calls `Repairable.gather(repository:correction:)` (Sources/iTunes/Patch/Repairable+Gather.swift), and returns a `Patch`.
2. `RepairDestination.emit` (Sources/iTunes/Patch/RepairDestination.swift) prints the patch as JSON to stdout, or writes a SQLite file (`--destination database --database-url PATH`).
3. `RepairCommand` (Sources/iTunes/Repair/RepairCommand.swift) takes a `Patchable` flag plus `--patch-url`, loads the file via `Patchable.createPatch` (Sources/iTunes/Patchable+URL.swift), and calls `Patch.patch` (Sources/iTunes/Repair/Patch+Build.swift).

`Patch` (Sources/iTunes/Patch.swift) is a single-case enum, `.identityRepairs([IdentityRepair])`. `Repairable` (Sources/iTunes/Patch/Repairable.swift) is the set of patch generators and includes the aggregates `libraryRepairs`, `historyRepairs`, `allRepairs`. `Patchable` (Sources/iTunes/Patchable.swift) is the same list without aggregates. Every `Patchable` case does the same thing (load the file), so the flag only chooses the default destination branch name (`rawValue`). `--destination-branch` overrides it.

`backup --patch-url` also applies a patch to freshly gathered tracks (`Track.backupPatch` in Sources/iTunes/Track+Patch.swift, called from Sources/iTunes/BackupCommand.swift) using the same engine.

### Patch file format

The file extension picks the loader (Sources/iTunes/Patch+URL.swift). `.json` decodes `[IdentityRepair]`. `.db` runs `SELECT * FROM correct_*` for 14 tables (Sources/iTunes/IdentityRepair+Database.swift). Any other extension throws `unknownPatchFileType`.

JSON is an array of `IdentityRepair` (Sources/iTunes/IdentityRepair.swift): `persistentID: UInt` plus a `correction` enum. Codable enum encoding is synthesized, so each element looks like `{"persistentID":123,"correction":{"duration":{"_0":201000}}}`. Cases: `duration(Int?)`, `persistentID(UInt)`, `dateAdded(String?)`, `composer`, `comments`, `dateReleased(String?)`, `albumTitle(SortableName?)`, `year`, `trackNumber`, `replaceSongTitle(SortableName)`, `discCount`, `discNumber`, `artist(SortableName?)`, `play(old:new:)`. Dates are ISO 8601 strings. `SortableName` (Sources/iTunes/SortableName.swift) is `{name, sorted}`. `sorted` is blanked when equal to `name`. Ordering uses `sorted` if present, else `name`.

The `.db` form is the hand-editable one (Sources/iTunes/CorrectionsDBContext.swift holds the schema). Each table is keyed by `itunesid` TEXT PRIMARY KEY. For example, `correct_song(itunesid, name, sort)`, `correct_play(itunesid, olddate, oldcount, newdate, newcount)`, `correct_id(itunesid, value)`. Inserts are `INSERT OR IGNORE`, so one correction per ID per table. The writer (`FlatDBEncoder`) prepares one INSERT from the first item of a call, so `Patch.writeDatabase` calls it once for each kind of correction. A call with mixed kinds would write the later kinds into the first kind's table without an error ([#944](https://github.com/bolsinga/itunes_json/issues/944)). Rows that fail to parse are dropped silently (`compactMap` in IdentityRepair+Database.swift, `init?(row:)` in Sources/iTunes/IdentityRepair+Row.swift).

### Truth models

Patching is driven by `Repairable.gather`. There are two truth models.

**Library as truth.** `.replaceDurations`, `.replaceComposers`, `.replaceComments`, `.replaceAlbumTitle`, `.replaceYear`, `.replaceTrackNumber`, `.replaceIdSongTitle`, `.replaceIdDiscCount`, `.replaceIdDiscNumber`, `.replaceArtist` (the `libraryCorrections` table in Repairable+Gather.swift). The generic `changes` function does the following.
- It reads current tracks from Music (`Source.itunes.gather(reduce: false)`).
- It builds a "guide" set (one `IdentityRepair` per track, SQL-encodable tracks only) from every historical tag.
- Unknown guides are those present in history but not in the current set. For each, it looks up the current guides with the same persistentID and keeps those whose correction value differs (`isCorrectionValueDifferent`).
- The emitted repair carries the current library value. Applying it rewrites old snapshots to match today's library.
- Tracks gone from the library produce no repair, since there is no current guide to compare.

**History as truth.** `.replaceDateAddeds`, `.replaceDateReleased`, `.replacePlay`. These fields cannot be edited in Music.app, and Music may reset them. `historicalChanges` collects guides per tag, sorts tags oldest to newest, and builds an ordered unique list per persistentID.
- `dateAdded`: IDs with more than one distinct value yield the *first* (oldest tag) value.
- `dateReleased`: same, but only among values that are non-nil. The earliest sorted is chosen.
- `play`: see below.

**Aggregates.** `libraryRepairs` merges all library patches in one pass over history. `historyRepairs` is date-added plus date-released only (play is excluded and marked experimental). `allRepairs` is both. `merge` unions sets and `sorted` orders by persistentID then correction.

**Misc.** `.replaceIdSongTitle` always rewrites the title, with no equality check (Track+Patch.swift `apply(correction:)`).

### Matching

Patch and repair match tracks strictly by `persistentID` (`Identifiable.id`). Treat persistent ID as the join key. Anything that changes persistent IDs breaks matching, which is why `replace-persistent-ids` exists.

### Play repair

`.replacePlay` (Sources/iTunes/Collection+PlayIdentity.swift, `PlayIdentity`, Play.swift) takes each track's tag-ordered plays and runs `[Play].normalize()`. Normalizing walks consecutive plays through `Play.check`. Good or duplicate entries pass, `updateCount` fixes a bad count, and invalid combinations (date and count moving in opposite directions) drop the entry and record a check string. Normalization only yields a repair if old and new arrays have the same length. Otherwise it logs "Cannot Normalize" and skips the ID. Each differing pair becomes `.play(old:, new:)`.

Application is conditional: `Track.apply(correction:)` changes a track only if its current play equals `old` and `new` has both date and count. This makes play repairs safe to replay but exact-match only.

`Date.compareQuirk` (Sources/iTunes/Date+Quirk.swift) treats two dates whose difference is a whole number of hours as `orderedSameQuirk`. This hides daylight-saving or timezone-shift artifacts in play dates. Note that identical dates (distance 0) also hit this branch. `Optional<Comparable>.<` (Sources/iTunes/Optional+Comparable.swift) gives `IdentityRepair` a total order. Two nils compare as `lhs < rhs == true`, which is not a strict weak ordering and is only suitable for the sorting done here.

### `--correction` and `replace-persistent-ids`

`--correction` is a JSON dictionary string `{"oldID": newID}` (`identifierLookupCorrections`). For `.replacePersistentIds`, the tool injects `.persistentID(new)` repairs for each key. It then diffs those against the current library's `.persistentID(track.persistentID)` guides. Intended use: a track was re-added and received a new ID, so a hand-written mapping rewrites old snapshots to the new ID so history joins up.

### Applying a repair

`Patch.patch` (Sources/iTunes/Repair/Patch+Build.swift) does the following.
1. `repository.transformTracks` decodes every tagged snapshot concurrently (Sources/iTunes/Repository+Tracks.swift). Each is patched by `[Track].patchIdentityRepairs`, which groups repairs by persistentID and applies them in order.
2. `initialTag` of the results picks the first commit. If no tags exist, it returns silently.
3. Each tag's name is bumped with `StructuredTag.next` (`root-V<version+1>-<stamp>`, Sources/iTunes/StructuredTag.swift). A non-structured tag throws `unstructuredTag`.
4. `Git.write` (Sources/iTunes/Git+Write+TagData.swift) calls `status()`, creates a new branch at the initial commit, then for each tag oldest to newest writes the file, `git add`, commits (message: tag plus tool version) only if there is a diff, and always tags. Push, tag push and gc are commented out, so the result is local.

The original branch and tags are untouched. The new tags differ by version only, so they coexist. A snapshot unchanged by the patch gets a tag but no commit.

### Risks

- **`replace-persistent-ids`** is destructive to identity. It changes the join key, can merge two distinct tracks if the mapping collides, and later library repairs match on the new ID. Run it first, then regenerate other patches. README says to use it with caution.
- **Duration** is library truth, but Music's value drifts "at indeterminate moments" (comment in Repairable+Gather.swift). Repairs may churn.
- **Dropped rows**: a `.db` row with a NULL or malformed value silently vanishes.
- **Play repair** is experimental and excluded from `history-repairs`.
- Patch creation reads the entire history and the live library (needs Music permission), so it is slow and memory heavy (see the comment in Git+Write+TagData.swift).
- Repair requires the working tree to be clean (`status()`) and rewrites snapshots onto a new branch, so cleaning up old branches is manual.

## Open questions

1. **No track-count repair.** A `correct_trackcount` table exists, but `CorrectionsDBRow.trackcount` is always nil and there is no `Repairable` case for track counts. Flag names derive from the camelCase enum cases via `EnumerableFlag`.
2. **Patch rows are `INSERT OR IGNORE`.** Two different corrections for one ID in one type silently keep the first.
3. **`Patchable` duplicates `Repairable`.** `createPatch` is a switch with identical arms. Could `repair` take just a path and an optional branch name?
4. **`Optional<Comparable>.<`** treats nil < nil as true. Is that intentional?
