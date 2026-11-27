# RFC 0005: A Derived Archive Database

Status: Proposed (draft for discussion, nothing here is implemented)

## Summary

Build the normalized archive database from the existing git history with code, and without rewriting the history. Today's `itunes.json` is the most accurate source for everything about a song except its play count, play date and add date, so the database takes those fields from the newest data. It takes the play history from a fold over the snapshots, oldest first, with fixed rules for the cases where the history is wrong. Each step of the fold adds one snapshot, so the one-time build from history and the daily update are the same code. The data problems that block `archive` today become findings that the tool reports, and not errors that stop it.

This replaces the `archive` SQL (RFC 0003) and makes `patch` and `repair` (RFC 0002) unnecessary for building the database. It amends the plays part of the schema in RFC 0004.

## Motivation

`archive` does not finish on the full history, even with every lax flag. Each blocker is a piece of old data that the current design needs to be fixed first:

- **[#921](https://github.com/bolsinga/itunes_json/issues/921):** an artist's sort name is set on some tracks before others. The rename in `updateArtists` lands on a row that already exists and the `artistids` insert fails.
- **[#924](https://github.com/bolsinga/itunes_json/issues/924):** five persistent IDs appear twice in 939 snapshots, up to 2025-02-07.
- **[#929](https://github.com/bolsinga/itunes_json/issues/929):** 271 play dates are shared by different tracks, so `UNIQUE(date)` fails.
- **[#935](https://github.com/bolsinga/itunes_json/issues/935), [#936](https://github.com/bolsinga/itunes_json/issues/936):** tracks with year 0 (from 2014) and with no track count (from 2026) fail the strict checks. Every snapshot that has one fails to build.

The existing answer is to repair the data (RFC 0002): rewrite every tag onto a new branch. That has costs:

- It rewrites the git tags and commits, which RFC 0001 calls an on-disk contract.
- Each problem needs its own repair type, and some have none (no track count repair exists).
- It fixes old snapshots so that a per-snapshot schema check passes, when the database does not need old snapshots to describe the song.

Most of these problems are in fields that today's data already has right. They only block the database because `archive` reads the attributes from every snapshot. If the attributes come from the newest data, most of the blockers go away without touching the history.

The `archive` SQL is also long, has no unit tests, keeps every flat snapshot database in memory at once, and has no incremental path (RFC 0003, "The 'Future' goal and its limits").

## Principles

1. **The repository is the source. The database is derived from it.** The database is never edited and is always rebuildable from the history and the rules. A rule that turns out wrong is fixed in code, and the database is rebuilt.
2. **The history is never rewritten.** No tag or commit changes.
3. **The newest data wins for what Music can edit.** Names, sort names, track and disc numbers and counts, year and duration come from the newest snapshot that has the track.
4. **The history wins for what Music cannot edit or reset.** Play counts, play dates and the date added come from the history.
5. **A bad value is reported, never made up.** The code does not invent a year, a count or a date. It records a finding, so the author can fix the data in Music, and the database is rebuilt.
6. **One code path for a rebuild and for an update.** Both run the same step over one snapshot.

## Detailed design

### Two layers

| Layer | Tables | How it is written |
|---|---|---|
| **Catalog** | `artists`, `albums`, `songs` | Each run sets every track in the snapshot to its newest attributes. A track that is not in the snapshot keeps the row it has. |
| **Timeline** | `added`, `released`, `plays`, `playstate`, `findings` | Folded over the snapshots, oldest first. Append-only. |

Because the catalog is set from the newest data and not from a replay, there are no renames to track. A renamed artist or album is just a different name on the same song. The `artistids` and `albumids` mapping tables, and all of `updateArtists` and `updateAlbums`, are not needed. After a run, an artist or album that no song refers to is deleted.

### Catalog rules

- **Newest valid value.** For each attribute, the value comes from the newest snapshot in which the track has a valid one. For a track that is in the newest snapshot, this is almost always that snapshot. The fallback only matters for a value that is invalid in the newest snapshot and was valid before. Old snapshots are never checked against the schema, so a year 0 in 2015 does not matter if the newest data has a year.
- **Sort names.** An artist's sort name is the sort name that any of its tracks in the snapshot has. If two different non-empty sort names are found, that is a finding, and the one used is the most common, then the first alphabetically. This is what `updateArtists` does today with a sibling row, applied to one snapshot, and it removes the rename that fails in #921.
- **Duplicate persistent IDs ([#924](https://github.com/bolsinga/itunes_json/issues/924)).** A snapshot can have two different library entries with one ID. Before anything else reads it, the snapshot is reduced to one entry per ID. The entry kept is the one with the earliest `dateAdded`, then the smallest `size`, because the original file is the most likely to be in the next snapshot too. A stable choice matters more than a recent one, because the play fold below compares each snapshot with the one before it. The dropped entry gives a `duplicatePersistentID` finding. No snapshot after 2025-02-07 has one, so the newest data is not affected.
- **Tracks that are no longer in the library.** Their rows stay, with the attributes of the last snapshot that had them. Their plays are part of the listening history. This is decided. `songs` has a `lastseen` column, the tag of the newest snapshot that has the track, and a `removedsongs` view lists the songs whose `lastseen` is not `archivestate.lasttag`.
- **Invalid tracks.** A track that lacks a required number (RFC 0004, "Missing values") in every snapshot that has it gets a finding (`invalidTrack`, naming what is missing). The track is left out of the catalog and the timeline. This is the 132 tracks with year 0 and the 17 with no track count in the newest snapshot. It is a data problem to fix in Music, then rebuild. This is decided: the track is excluded, not given an unknown value, and its plays appear after the fix. See "Invalid tracks" for what happens when one is fixed.

### The play fold

For each song, the state is `seencount` and `seendate`: the last count and date that the fold accepted as a baseline. The cumulative play count is the `count` of the song's last row in `plays`. A snapshot gives each song an observation `(c, d)`: the `playCount` (a missing count is 0) and the `playDateUTC` (maybe empty). A count of 0 with a date is read as one play, as `Play.normalize` does today.

The rule from the author's notes is that a play count only increases, and when it increases the play date moves forward, and a play date never moves back. Music does not always keep to it, because it sometimes loses a date or resets a count to zero. These are the cases, checked in order. "Forward" means `d` is later than `seendate` by more than the DST quirk. The quirk is a difference that is a whole number of hours, of any size, which includes 0. This is the rule of `Date.compareQuirk`, so the fold needs no new rule, and the 12 hour bound in the archive SQL goes away with that SQL.

| # | Observation compared with the state | What the fold does | Finding |
|---|---|---|---|
| 1 | The song has no state yet, `c > 0`, `d` present | Add a play of `c` at `d`. Set the state to `(c, d)`. | none |
| 2 | No state yet, `c > 0`, `d` empty | Set the state to `(c, '')`. No play. | `noPlayDate` |
| 3 | `c == seencount`, `d` empty or equal up to the quirk | Nothing. | none |
| 4 | `c > seencount`, `d` forward | Add a play of `c - seencount` at `d`. Advance the state to `(c, d)`. | none |
| 5 | `c > seencount`, `d` empty or not forward | No play. The state does not change, so the next good observation counts these plays. | `countUpDateNotForward` |
| 6 | `c < seencount`, `d` forward | The count was reset and the song was played. Add a play of `max(c, 1)` at `d`. Set the state to `(c, d)`. | `countReset` |
| 7 | `c < seencount`, `d` empty or not forward | No play. Set the state to `(c, seendate)`, so later plays count from the lower number. | `countDecreased` |
| 8 | `c == seencount`, `d` forward | No play. Move `seendate` to `d`. | `dateForwardNoCount` |
| 9 | `c == seencount`, `d` back by more than the quirk | Nothing. | `dateBackward` |

Cases 4 and 6 are what `Play.normalize` already does, so the new code keeps the two interpretations the author reached while repairing plays. Case 6 is the one that existing code calls `updateCount`. It is decided that a count that drops while the date moves forward is a reset followed by plays, so the song's total keeps growing across the reset. Cases 5 and 7 are among the ones it drops with an `invalid...` check, which stops the song's fold at that observation. The difference is that here a dropped observation does not abandon the song. It either leaves the baseline alone (5, 9) or moves it down (7), so the next snapshot is compared with something real, and a reset or a lost date no longer makes the later plays invisible.

A play is a delta. Snapshots are not one per play, so a song can be played several times between two of them. The row has the last known date, and the earlier plays of that delta are in the time between the previous date and this one. This is the shape the author describes, and it replaces the row-per-play shape that the finer granularity would have given.

### Shared play dates ([#929](https://github.com/bolsinga/itunes_json/issues/929))

Two songs can have one date. The fold stores the dates as they are. Moving a date (for example back by the summed durations of the tracks before it) would invent data, and the largest groups, 74 tracks on one second in 2007, would move by hours. The schema drops `UNIQUE(date)` and keeps `UNIQUE(itunesid, date)`. Ordering plays by `(date, itunesid)` is stable. A view lists the shared dates so they stay visible, and each one is a `sharedPlayDate` finding.

### Date added and date released

These cannot be edited in Music, and Music may reset them, so the history decides (RFC 0002 reaches the same rule for repair).

- **`added`:** the first non-empty `dateAdded` the track had, in tag order. Later values that differ by more than the quirk are a `dateAddedChanged` finding.
- **`released`:** the first non-empty `releaseDate` in tag order. A track with none has no row, as today.

### Findings

A finding is `(tag, persistentID?, code, detail)`. They are written to a `findings` table in the database in the same transaction as the rows that caused them. The codes above are the first set:

- `invalidTrack`, `duplicatePersistentID`, `sortNameConflict`, `sharedPlayDate`, `dateAddedChanged`
- `noPlayDate`, `countUpDateNotForward`, `countReset`, `countDecreased`, `dateForwardNoCount`, `dateBackward`

The same codes are the validation of the newest `itunes.json`. After `backup` writes and commits a snapshot, the checks that need no state (`invalidTrack`, `duplicatePersistentID`, `sortNameConflict`, `sharedPlayDate`) can run on that snapshot alone and be reported to the person running it. The checks that compare with the previous snapshot need the database state. A finding never stops the backup, because the JSON is the record. Findings are kept in the database and written to the log. Showing them in the iTunesJson app, for example as a notification with a count and the first few tracks, is deferred until the archive works. It is decided not to design the app side now.

### Schema changes (amends RFC 0004)

```sql
CREATE TABLE IF NOT EXISTS plays (
  id INTEGER PRIMARY KEY,
  itunesid TEXT NOT NULL,
  date TEXT NOT NULL,
  delta INTEGER NOT NULL,            -- plays since the previous row, last played at date
  count INTEGER NOT NULL,            -- the derived total after this row
  tag TEXT NOT NULL,                 -- the snapshot that showed it
  UNIQUE(itunesid, date),
  FOREIGN KEY(itunesid) REFERENCES songs(itunesid),
  CHECK(length(date) > 0),
  CHECK(delta > 0),
  CHECK(count >= delta)
) STRICT;
CREATE TABLE IF NOT EXISTS playstate (
  itunesid TEXT NOT NULL PRIMARY KEY,
  seencount INTEGER NOT NULL,
  seendate TEXT NOT NULL,            -- '' when it has never been seen with a date
  FOREIGN KEY(itunesid) REFERENCES songs(itunesid)
) STRICT;
CREATE TABLE IF NOT EXISTS findings (
  id INTEGER PRIMARY KEY,
  tag TEXT NOT NULL,
  itunesid TEXT,                     -- NULL when the finding is not about one track
  code TEXT NOT NULL,
  detail TEXT NOT NULL
) STRICT;
CREATE TABLE IF NOT EXISTS archivestate (
  key TEXT NOT NULL PRIMARY KEY,     -- lasttag, schemaversion, toolversion
  value TEXT NOT NULL
) STRICT;
```

- **`UNIQUE(date)` is gone from `plays`.** `count` is the derived total, which can differ from Music's count where Music reset it. `plays` stores both `delta` and `count`, so queries that read `plays.count` keep working. They are written in the same insert, and a test checks that `count` is the running sum of `delta`. This is decided.
- **`songs` gets `lastseen TEXT NOT NULL`**, the tag of the newest snapshot that has the track, and a `removedsongs` view.
- **`artistids` and `albumids` are removed.**
- **The strict and lax flags do not apply to `archive`.** The rules produce data that satisfies the strict schema, so lax is not needed.
- **Views.** `lastplays` and `tracks` keep their meaning.

### Update and rebuild

`archivestate.lasttag` is the newest tag applied. An update applies the newest tag in one transaction that also writes `lasttag`. It refuses a tag that is not newer than `lasttag`. A rebuild starts from an empty database and applies every tag, oldest first, in the same way. The tags are ordered by their date, as `archive` orders them today.

Updates come from a separate `archive` run, and `backup` stays as it is. This is decided. A verify mode compares the database with a rebuild. Once that is trusted, `backup` can get an option that runs both in one go.

A rebuild and an update must give the same database. That gives a check for the period the author wants, when the repository and the database are both updated each day: build the database again from the whole history into a temporary file and compare every table with the updated one. A difference means a bug in the rules or in the step.

### Invalid tracks

A track that is excluded for an `invalidTrack` finding has no `songs` row, so it cannot have `plays` rows, and its plays are not folded. When the author fixes it in Music, the next snapshot has a valid track, and an update would count all its plays as one row at that date. To keep the timeline right, the update checks whether a track with an open `invalidTrack` finding is now valid, and if so it stops and asks for a rebuild, which folds the whole history for that track. A rebuild is cheap. The existing run reached the failure after about 5 minutes on a 14 core machine, and the new code decodes the snapshots the same way.

### The step, in code

The fold is a plain Swift function, so it can be tested without SQLite or git.

```swift
struct PlayObservation: Sendable { let count: Int; let date: String? }
struct PlayState: Sendable { var seenCount: Int; var seenDate: String }
struct PlayStep: Sendable {
  let state: PlayState
  let play: (date: String, delta: Int)?
  let finding: FindingCode?
}

func step(_ state: PlayState?, _ observation: PlayObservation) -> PlayStep
```

A snapshot step reduces the snapshot (one entry per ID), compares each track with its state, and gives the rows to write. It holds the states of about 16,000 songs in a dictionary and writes only the rows that change. A rebuild reads one snapshot at a time, so memory no longer grows with the length of the history. The snapshots can still be decoded in parallel, but they are applied in tag order, with a small bound on how many wait.

### The flat databases

Each snapshot does not become a flat database on the way to the archive. The step reads the decoded `[Track]` directly. That removes the in-memory database per tag and the SQL strings, and the rules can be tested with a few `Track` values. The flat format stays what it is today, a way to study one snapshot with SQL (`batch --flat`, `query`).

### What happens to the existing commands

- **`archive`:** new implementation, same name. Its SQL constants and its lax flags go away.
- **`patch` and `repair`:** not needed to build the database. They can stay while the new `archive` is checked against the history, then be removed. What they do for the database moves as follows:

  | What repair does | In this design |
  |---|---|
  | Library fixes (titles, track and disc numbers, years, durations, artists) so old snapshots pass a strict check | Not needed. The attributes come from the newest data. |
  | `replaceDateAddeds`, `replaceDateReleased` | The `added` and `released` rules above. |
  | `replacePlay` | The play fold. `Play.normalize` is replaced by the same cases. |
  | `replace-persistent-ids` | No equivalent yet. A track whose ID changes is a new song with a new history. See the open questions. |

- **`batch` and `query`:** unchanged. They remain the way to look at the data.
- **`backup`:** unchanged. Once the archive is trusted it may gain an option that applies the new snapshot to the database after committing it.

## Alternatives considered

- **Keep repairing the data.** It rewrites tags, each problem needs a repair type, and it does not decide how a reset or a lost date is treated.
- **Fix the archive SQL one problem at a time.** Each fix (for example #921) adds more SQL that is hard to review and has no tests. The rules are clearer as a Swift function.
- **Make every snapshot a flat database, then fill the archive from them.** This is what `archive` does today. It costs memory for every snapshot and keeps the rules in SQL, and the flat database adds nothing the decoded tracks do not already have.
- **Shift duplicate play dates.** The branch behind the comment on #929 did this. It invents dates, and the choice of which track keeps the date is arbitrary.
- **Use NULL for unknown values.** RFC 0004 explains why not: a `CHECK` accepts NULL and `UNIQUE` treats NULLs as distinct, which would hide the problem the finding reports.

## Risks

- **A play a whole number of hours after the last one is read as the quirk.** If a song is played again exactly 24 hours later, to the second, with a higher count, it is case 5. The baseline does not move, so the next good observation counts the play, a little later than it happened. It is not lost.
- **A conservative reset rule loses plays.** Case 7 records no play when a count drops and the date does not move forward. Plays between the reset and the next observation are not counted. The findings show how often that happens, and the rule can change before the next rebuild.
- **Case 6 can add plays that did not happen.** If a drop in the count is a glitch and not a reset, the fold adds the lower count as new plays. Each one is a `countReset` finding, so they can be listed and checked.
- **The newest data is trusted.** An edit in Music applies to the whole history. This is the aim, and the history keeps the old values.
- **The derived `count` is not Music's `playCount`.** They differ for a song that was reset. The `countReset` findings list them.
- **Two copies of one ID.** The rule picks the original file. Whether both copies record plays is not known.

## Verification plan

The rules are untested on the full history, so these come first:

1. Run the fold with no database and count the findings by code. This shows how common each case is, and whether case 7 loses many plays.
2. For every song with no reset finding, check that the derived `count` after the newest snapshot equals Music's `playCount`.
3. Check that an update of one snapshot equals a rebuild.
4. For each of the five duplicated IDs, compare the two entries' play counts and dates across the 939 snapshots. This shows whether both copies record plays, and whether the entry the rule keeps is the one that moves.
5. List candidates for a changed ID: the same artist, album and name, where one ID stops appearing and another starts.
6. Check that `plays.count` equals the running sum of `plays.delta` for every song.
7. Count the compilations that split into several albums because their tracks have different artists.
8. Use fixtures that have a known problem: the Neil Young sort name from 2025-05-30 to 2025-06-01 (#921), and a duplicate ID from #924.

## Open questions

1. **Duplicate persistent IDs.** Do both copies record plays? If they do, keeping the original copy ignores the plays of the other. The first full run measures it (see the verification plan).
2. **A track whose ID changes.** The design has no equivalent of `replace-persistent-ids`. Is a small hand-kept alias list worth adding, if this happens in the data? The first full run lists candidates (see the verification plan), and aliases are added only if they show up.
3. **Album identity.** An album is identified by its artist, name, counts and compilation flag (RFC 0004), so a compilation with several track artists is several albums. This RFC does not change that. The first full run counts how many compilations split into several albums (see the verification plan).
