# RFC 0005: A Derived Archive Database

Status: Accepted (approved 2026-11-27; implementation is in progress, see the PRs labeled RFC 0005)

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
7. **No timing fidelity is lost.** A date is stored exactly as the snapshot recorded it. The archive never rounds, shifts or reformats one. See "Date fidelity".

## Detailed design

### Two layers

| Layer | Tables | How it is written |
|---|---|---|
| **Catalog** | `artists`, `albums`, `songs` | Each run sets every track in the snapshot to its newest attributes. A track that is not in the snapshot keeps the row it has. |
| **Timeline** | `added`, `released`, `plays`, `playstate`, `findings` | Folded over the snapshots, oldest first. Append-only. |

Because the catalog is set from the newest data and not from a replay, there are no renames to track. A renamed artist or album is just a different name on the same song. The `artistids` and `albumids` mapping tables, and all of `updateArtists` and `updateAlbums`, are not needed. After a run, an artist that no song or album refers to is deleted, and an album that no song refers to is deleted. Each is logged before it is deleted: an `artistRemoved` or `albumRemoved` finding in the same transaction holds the whole row (for an artist its name and sort name, for an album its owner, name, sort name, counts and compilation flag), and it is also written to the log. This is decided.

### Catalog rules

- **Newest valid value.** For each attribute, the value comes from the newest snapshot in which the track has a valid one. For a track that is in the newest snapshot, this is almost always that snapshot. The fallback only matters for a value that is invalid in the newest snapshot and was valid before. Old snapshots are never checked against the schema, so a year 0 in 2015 does not matter if the newest data has a year.
- **Sort names.** An artist's sort name is the sort name that any of its tracks in the snapshot has. This is what `updateArtists` does today with a sibling row, applied to one snapshot, and it removes the rename that fails in #921. Two cases are logged, so they can be found and counted:
  - **`sortNameFilled`:** some tracks of an artist have a sort name and others have none (#941). The sort name is filled in for all of them, and the finding holds the artist, the sort name used, and how many tracks had it and how many did not. This is decided. It is a report to learn from: if the cases turn out to be harmless, the report can be removed, and if they are worth fixing, the finding lists them.
  - **`sortNameConflict`:** two different non-empty sort names are found. The one used is the most common, then the first alphabetically.
- **Duplicate persistent IDs ([#924](https://github.com/bolsinga/itunes_json/issues/924)).** A snapshot can have two different library entries with one ID. Before anything else reads it, the snapshot is reduced to one entry per ID. The entry kept is the one with the earliest `dateAdded`, then the smallest `size`, because the original file is the most likely to be in the next snapshot too. A stable choice matters more than a recent one, because the play fold below compares each snapshot with the one before it. The dropped entry gives a `duplicatePersistentID` finding. No snapshot after 2025-02-07 has one, so the newest data is not affected.
- **Album owner (decided).** Today an album belongs to the track's artist (`artist ?? albumArtist`), so a compilation whose tracks have different artists becomes one album for each of them. The owner of an album is now, in this order:
  1. the track's `albumArtist`, if it is not empty, with its `sortAlbumArtist` as the sort name;
  2. otherwise, if the track has the compilation flag, the artist named `Various Artists`;
  3. otherwise the track's artist, as today.

  The `Various Artists` row is an ordinary `artists` row. A compilation that has `Various Artists` as its Album Artist in Music and one that gets it from rule 2 are the same row. A compilation that gets the owner from rule 2 writes a `compilationNoAlbumArtist` finding, so each one is listed and can be fixed by setting the Album Artist in Music. This is the only stand-in name in the design, and it is fixed and visible. A song keeps its own track artist in `songs.artistid`. Only `albums.artistid` is the owner.
- **Album identity (decided).** An album is `(owner, name, trackcount, disccount, discnumber, compilation)`, as in RFC 0004 with the owner changed. Disc number stays in the identity, so each disc of a multi-disc album is its own album row, and the discs of one compilation are separate rows under one owner. Tracks of one disc that disagree on a count or on the compilation flag are still split, and so are the tracks of a compilation where only some have an Album Artist. It is decided to log each such case as an `albumSplit` finding and leave the identity as it is. The first full run shows how often it happens, and the findings show how to fix it.

  - **When it is written.** Tracks are grouped by album name and disc number. A group is a split when it would become more than one album row for one of two reasons. Either the tracks have the same owner and differ in track count, disc count or compilation flag, or at least one track has the compilation flag and the tracks differ in owner. Albums with the same name by different artists are not a split, because neither has the compilation flag.
  - **What it holds.** The album name and disc number, the reason, each variant (the owner, track count, disc count and compilation flag) with how many tracks have it, and the persistent IDs of the tracks that are not in the most common variant. These are the tracks to look at in Music, and they show whether taking the most common value would be right.
- **Tracks that are no longer in the library.** Their rows stay, with the attributes of the last snapshot that had them. Their plays are part of the listening history. This is decided. `songs` has a `lastseen` column, the tag of the newest snapshot that has the track, and a `removedsongs` view lists the songs whose `lastseen` is not `archivestate.lasttag`.
- **Invalid tracks.** A track that lacks a required number (RFC 0004, "Missing values") in every snapshot that has it gets a finding (`invalidTrack`, naming what is missing). The track is left out of the catalog and the timeline. This is the 132 tracks with year 0 and the 17 with no track count in the newest snapshot. It is a data problem to fix in Music, then rebuild. This is decided: the track is excluded, not given an unknown value, and its plays appear after the fix. See "Invalid tracks" for what happens when one is fixed.

### The play fold

For each song, the state is `seencount` and `seendate`: the last count and date that the fold accepted as a baseline. The cumulative play count is the `count` of the song's last row in `plays`. A snapshot gives each song an observation `(c, d)`: the `playCount` (a missing count is 0) and the `playDateUTC` (maybe empty). A count of 0 with a date is read as one play, as `Play.normalize` does today.

The rule from the author's notes is that a play count only increases, and when it increases the play date moves forward, and a play date never moves back. Music does not always keep to it, because it sometimes loses a date or resets a count to zero. These are the cases, checked in order. "Forward" means `d` is later than `seendate` by more than the DST quirk. An empty `seendate` is earlier than any date. The quirk is a difference of exactly one hour, either way, because that is what daylight saving time does to an unchanged date. Dates are whole seconds, so the difference is exact. A difference of 0 is the same date. This is the rule of `Date.compareQuirk`, which is changed to it, and the whole-hour rule of any size and the 12 hour bound in the archive SQL go away.

| # | Observation compared with the state | What the fold does | Finding |
|---|---|---|---|
| 1 | The song has no state yet, `c > 0`, `d` present | Add a play of `c` at `d`. Set the state to `(c, d)`. | none |
| 2 | No state yet, `c > 0`, `d` empty | No play. Set the state to `(0, '')`, so these plays are counted when a date appears. | `noPlayDate` |
| 3 | `c == seencount`, `d` empty or equal up to the quirk | Nothing. | none |
| 4 | `c > seencount`, `d` forward | Add a play of `c - seencount` at `d`. Advance the state to `(c, d)`. | none |
| 5 | `c > seencount`, `d` empty or not forward | No play. The state does not change, so the next good observation counts these plays. | `countUpDateNotForward` |
| 6 | `c < seencount`, `d` forward | The count was reset and the song was played. Add a play of `max(c, 1)` at `d`. Set the state to `(c, d)`. | `countReset` |
| 7 | `c < seencount`, `d` empty or not forward | No play. Set the state to `(c, seendate)`, so later plays count from the lower number. | `countDecreased` |
| 8 | `c == seencount`, `d` forward | No play. Move `seendate` to `d`. | `dateForwardNoCount` |
| 9 | `c == seencount`, `d` back by more than the quirk | Nothing. | `dateBackward` |

A song with no state, a count of 0 and no date has never been played, and gets no state. `seendate` is empty only while `seencount` is 0.

Cases 4 and 6 are what `Play.normalize` already does, so the new code keeps the two interpretations the author reached while repairing plays. Case 6 is the one that existing code calls `updateCount`. It is decided that a count that drops while the date moves forward is a reset followed by plays, so the song's total keeps growing across the reset. Cases 5 and 7 are among the ones it drops with an `invalid...` check, which stops the song's fold at that observation. The difference is that here a dropped observation does not abandon the song. It either leaves the baseline alone (5, 9) or moves it down (7), so the next snapshot is compared with something real, and a reset or a lost date no longer makes the later plays invisible.

A play is a delta. Snapshots are not one per play, so a song can be played several times between two of them. The row has the last known date, and the earlier plays of that delta are in the time between the previous date and this one. This is the shape the author describes, and it replaces the row-per-play shape that the finer granularity would have given.

#### Worked examples

Cases 3 to 9 start from a song with a baseline of 40 plays, last played Mar 1. Cases 1 and 2 start from a song the archive has not seen.

| # | What the next snapshot shows | What the fold does | Total after |
|---|---|---|---|
| 1 | First seen, 12 plays, last played Feb 3 | Add 12 plays at Feb 3. | 12 |
| 2 | First seen, 12 plays, no date. Later: 12 plays, Feb 3 | No play at first. When the date appears it is case 4: add 12 plays at Feb 3. | 0, then 12 |
| 3 | 40 plays, Mar 1 (or no date) | Nothing. | 40 |
| 4 | 43 plays, Mar 9 | Add 3 plays at Mar 9. | 43 |
| 5 | 43 plays, no date. Later: 44 plays, Mar 12 | No play at first, and the baseline stays at 40. Later it is case 4: add 4 plays at Mar 12, which include the 3. | 40, then 44 |
| 6 | 3 plays, Mar 9 | A reset, then 3 plays. Add 3 plays at Mar 9. The baseline becomes 3, Mar 9. | 43 |
| 7 | 3 plays, no date (or Mar 1) | No play. The baseline becomes 3, Mar 1, and the finding keeps the 3. Later: 5 plays, Mar 12. That is case 4: add 2 plays at Mar 12. | 40, then 42 |
| 8 | 40 plays, Mar 9 | No play. The baseline date becomes Mar 9. | 40 |
| 9 | 40 plays, Feb 20 | Nothing. The baseline stays. | 40 |

### Shared play dates ([#929](https://github.com/bolsinga/itunes_json/issues/929))

Two songs can have one date. The fold stores the dates as they are. Moving a date (for example back by the summed durations of the tracks before it) would invent data, and the largest groups, 74 tracks on one second in 2007, would move by hours. The schema drops `UNIQUE(date)` and keeps `UNIQUE(itunesid, date)`. Ordering plays by `(date, itunesid)` is stable. A view lists the shared dates so they stay visible, and each one is a `sharedPlayDate` finding.

### Date added and date released

These cannot be edited in Music, and Music may reset them, so the history decides (RFC 0002 reaches the same rule for repair).

- **`added`:** the first non-empty `dateAdded` the track had, in tag order. Later values that differ by more than the quirk are a `dateAddedChanged` finding.
- **`released`:** the first non-empty `releaseDate` in tag order. A track with none has no row, as today.

### Date fidelity

It is decided that no timing fidelity is lost from the source data.

- **The archive stores dates verbatim.** A play date, a date added and a date released are written as the snapshot has them, as the same string. They are not parsed and written back, rounded, shifted or normalized. The quirk and the cases above only decide which observation counts. They never change a stored date.
- **Dates are ISO 8601 strings,** as RFC 0001 documents, and are read with that standard's definition.

**The DST shift (#328) is a bug in Music, and nothing here can fix it.** An unchanged date from the library moves by one hour when daylight saving time starts and ends. The history already recorded those values. The archive does not try to correct them. A date that moves by exactly one hour with the same count is read as the same date (case 3), so a shift does not add a play. A larger move is not a quirk, and is a finding (case 8 or 9). The stored date is the one from the first observation, verbatim, and the later shifted values stay in the history. A case 3 observation does not write a finding, because it would add one for most played songs at every change.

### Findings

A finding is `(tag, persistentID?, code, detail)`. They are written to a `findings` table in the database in the same transaction as the rows that caused them. The codes above are the first set:

- `invalidTrack`, `duplicatePersistentID`, `sortNameConflict`, `sharedPlayDate`, `dateAddedChanged`, `compilationNoAlbumArtist`, `albumSplit`, `sortNameFilled`, `artistRemoved`, `albumRemoved`
- `noPlayDate`, `countUpDateNotForward`, `countReset`, `countDecreased`, `dateForwardNoCount`, `dateBackward`

**Nothing is dropped without a record.** Every observation that the fold does not apply in full writes a finding. That is every case in the play table except 1, 3 and 4. Case 3 is the same as the state, so there is nothing to record.

- **What a finding holds:** the tag, the state before (`seencount`, `seendate`), the observation `(c, d)`, and what the fold did (the plays added, and the new state). This is what is needed to apply the observation differently later. It is also written to the log when it is written.
- **Cases that add a play:** case 6 adds plays, and its finding says how many. In the example above, the finding says `countReset`, with the state `(40, Mar 1)`, the observation `(3, Mar 9)`, and the 3 plays added.
- **Cases that add no play:** cases 2, 5, 7, 8 and 9 add no play, so their findings are the only place that observation is kept.
- **Case 7 is decided to stay log-only.** A count that drops while the date does not move forward adds no play. The lower count and its date are kept in the finding, so no data is lost at this point. The history is not changed either, so a later rebuild can read the same snapshots with a different rule. The first full run shows how many case 7 findings there are before that is revisited.
- **No repeats.** A finding about a song is not written again when the song's last finding with the same code has the same detail apart from the tag. A finding that is not about a song (an artist or an album) is not written again while the previous snapshot had it, so one that goes away and comes back is written again. Without this, a song that stays in the same state would add a finding for every snapshot, which is 1,611 rows for each of the 132 tracks with year 0. The first one is kept, with the tag where it began.

The same codes are the validation of the newest `itunes.json`. After `backup` writes and commits a snapshot, the checks that need no state (`invalidTrack`, `duplicatePersistentID`, `sortNameConflict`, `sharedPlayDate`, `compilationNoAlbumArtist`, `albumSplit`, `sortNameFilled`) can run on that snapshot alone and be reported to the person running it. The checks that compare with the previous snapshot need the database state. A finding never stops the backup, because the JSON is the record. Findings are kept in the database and written to the log. Showing them in the iTunesJson app, for example as a notification with a count and the first few tracks, is deferred until the archive works. It is decided not to design the app side now.

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
  seendate TEXT NOT NULL,            -- '' while nothing has been accepted (seencount is then 0)
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
- **`albums.artistid` is the album owner**, not the track's artist (see "Catalog rules"). `songs.artistid` stays the track's artist.
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

func foldPlayObservation(_ state: PlayState?, _ observation: PlayObservation) -> PlayStep
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

## Plan for each Data issue

Each open issue labeled Data has a plan. They fall into four kinds.

| Issue | Kind | Plan |
|---|---|---|
| [#921](https://github.com/bolsinga/itunes_json/issues/921) `archive` fails on `artistids` | Removed by the design | No `artistids` table and no rename. Sort names come from one snapshot. |
| [#941](https://github.com/bolsinga/itunes_json/issues/941) (closed) sort name on some tracks only | Handled and logged | The sort name is filled in from the other tracks, and each case is a `sortNameFilled` finding, to learn whether it is worth fixing. |
| [#924](https://github.com/bolsinga/itunes_json/issues/924) duplicate persistent IDs | Handled and measured | One entry is kept, and a `duplicatePersistentID` finding is written. Whether both copies record plays is measured on the first full run. |
| [#929](https://github.com/bolsinga/itunes_json/issues/929) shared play dates | Recorded as found | Dates are stored verbatim, and each shared date is a `sharedPlayDate` finding. |
| [#328](https://github.com/bolsinga/itunes_json/issues/328) DST shift | Not fixable here | A bug in Music. The history has the values, and the archive reads a shift of exactly one hour as the same date. |
| [#935](https://github.com/bolsinga/itunes_json/issues/935) year 0, [#936](https://github.com/bolsinga/itunes_json/issues/936) no track count | Fix it in Music | The track is excluded and reported until the next snapshot is good. |

**Fix it in Music.** #935 and #936 are a class of issue whose fix is to correct the track in the Music app, so that the next snapshot is good. The archive does nothing special for them beyond the `invalidTrack` finding. The author expects the newest Music data to have them fixed already, so the first full run should report none for the newest snapshot. If it reports any, they are in this class and are fixed the same way, and an update that sees a track become valid asks for a rebuild (see "Invalid tracks").

## Alternatives considered

- **Keep repairing the data.** It rewrites tags, each problem needs a repair type, and it does not decide how a reset or a lost date is treated.
- **Fix the archive SQL one problem at a time.** Each fix (for example #921) adds more SQL that is hard to review and has no tests. The rules are clearer as a Swift function.
- **Make every snapshot a flat database, then fill the archive from them.** This is what `archive` does today. It costs memory for every snapshot and keeps the rules in SQL, and the flat database adds nothing the decoded tracks do not already have.
- **Shift duplicate play dates.** The branch behind the comment on #929 did this. It invents dates, and the choice of which track keeps the date is arbitrary.
- **Use NULL for unknown values.** RFC 0004 explains why not: a `CHECK` accepts NULL and `UNIQUE` treats NULLs as distinct, which would hide the problem the finding reports.

## Risks

- **A play exactly one hour after the last one is read as the quirk.** If a song is played again exactly one hour later, to the second, with a higher count, it is case 5. The baseline does not move, so the next good observation counts the play, a little later than it happened. It is not lost. Shifts of other sizes, such as a time zone change, are not read as the quirk, and show up as `dateForwardNoCount` and `dateBackward` findings. The first full run lists them, to learn whether the rule needs to be wider.
- **Case 7 counts no plays.** When a count drops and the date does not move forward, the fold adds no play, so any plays at the lower count are not in the total. The observation is kept in a `countDecreased` finding, and the history still has it. The findings show how often that happens, and the rule can change before the next rebuild.
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
7. Count the compilations that get the `Various Artists` owner (`compilationNoAlbumArtist`), and the `albumSplit` findings, by reason. These show how many albums still split, and which tracks cause it.
8. Check that the newest snapshot gives no `invalidTrack` finding. The author expects #935 and #936 are fixed in the newest Music data.
9. Count `sortNameFilled` findings by artist and by snapshot, to decide whether to keep the report (#941).
10. Use fixtures that have a known problem: the Neil Young sort name from 2025-05-30 to 2025-06-01 (#921), and a duplicate ID from #924.

## Open questions

1. **Duplicate persistent IDs.** Do both copies record plays? If they do, keeping the original copy ignores the plays of the other. The first full run measures it (see the verification plan).
2. **A track whose ID changes.** The design has no equivalent of `replace-persistent-ids`. Is a small hand-kept alias list worth adding, if this happens in the data? The first full run lists candidates (see the verification plan), and aliases are added only if they show up.
