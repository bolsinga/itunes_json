//
//  IDChanges.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation

/// A track whose persistent ID may have changed: one ID stops appearing in the snapshots, and
/// another ID with the same artist, album, name and track number starts appearing soon after. See
/// RFC 0005, open question 2.
struct IDChange: Equatable, Sendable {
  let oldID: UInt
  let newID: UInt
  let name: String
  let artist: String
  let album: String
  let trackNumber: Int
  /// The last snapshot that has the old ID, and the first one that has the new ID.
  let lastTag: String
  let firstTag: String
  /// How many snapshots are between them. 0 is the very next one.
  let gap: Int
  /// What the two showed at the last and at the first snapshot. The same count and date means the
  /// plays moved with the track.
  let oldPlays: PlayObservation
  let newPlays: PlayObservation

  var playsCarried: Bool { oldPlays == newPlays && oldPlays.count > 0 }

  var text: String {
    func plays(_ observation: PlayObservation) -> String {
      "\(observation.count) at \(observation.date ?? "no date")"
    }
    return
      "\(oldID) -> \(newID)  \"\(name)\" by \(artist) on \"\(album)\" (track \(trackNumber)): last \(lastTag), first \(firstTag), \(gap) snapshot(s) between, plays \(plays(oldPlays)) -> \(plays(newPlays))\(playsCarried ? " (carried)" : "")"
  }
}

/// Finds the tracks whose ID may have changed, over the snapshots, which are added oldest first.
struct IDChangeFinder: Sendable {
  private struct Key: Hashable, Sendable {
    let artist: String
    let album: String
    let name: String
    let trackNumber: Int
  }

  private struct Sighting: Sendable {
    let index: Int
    let tag: String
    let key: Key
    let plays: PlayObservation
  }

  private var first = [UInt: Sighting]()
  private var last = [UInt: Sighting]()
  private var snapshots = 0

  /// Adds the music of the next snapshot. An ID that two entries have is read from the first one.
  mutating func add(_ snapshot: Tag<[Track]>) {
    var seen = Set<UInt>()
    for track in snapshot.item where track.isSQLEncodable {
      guard seen.insert(track.persistentID).inserted else { continue }
      let sighting = Sighting(
        index: snapshots, tag: snapshot.tag,
        key: Key(
          artist: track.artistName?.name ?? "", album: track.album ?? "", name: track.name,
          trackNumber: track.trackNumber ?? 0),
        plays: PlayObservation(count: track.playCount ?? 0, date: track.playDateUTC))
      if first[track.persistentID] == nil { first[track.persistentID] = sighting }
      last[track.persistentID] = sighting
    }
    snapshots += 1
  }

  /// The IDs that are gone from the newest snapshot, and have a successor within `window` snapshots:
  /// a different ID that is not in a snapshot until after, and that first looked like the old ID
  /// last did. Only the successors that come first count. An ID that is there at the same time as the old one is not a successor.
  func changes(window: Int = 3) -> [IDChange] {
    var successors = [Key: [UInt]]()
    for (id, sighting) in first { successors[sighting.key, default: []].append(id) }

    var changes = [IDChange]()
    for (oldID, old) in last where old.index < snapshots - 1 {
      let candidates = (successors[old.key] ?? []).compactMap { newID -> (UInt, Sighting)? in
        guard newID != oldID, let new = first[newID], new.index > old.index,
          new.index - old.index - 1 <= window
        else { return nil }
        return (newID, new)
      }
      // Only the successors that come first. An ID that came later is the successor's successor.
      let nearest = candidates.map(\.1.index).min()
      for (newID, new) in candidates where new.index == nearest {
        changes.append(
          IDChange(
            oldID: oldID, newID: newID, name: old.key.name, artist: old.key.artist,
            album: old.key.album, trackNumber: old.key.trackNumber, lastTag: old.tag,
            firstTag: new.tag, gap: new.index - old.index - 1, oldPlays: old.plays,
            newPlays: new.plays))
      }
    }
    return changes.sorted { ($0.lastTag, $0.oldID, $0.newID) < ($1.lastTag, $1.oldID, $1.newID) }
  }
}

extension Repository {
  /// The tracks whose ID may have changed, read from every snapshot of the repository.
  func idChanges(window: Int = 3) async throws -> [IDChange] {
    var finder = IDChangeFinder()
    for try await snapshot in try await snapshots(after: nil) { finder.add(snapshot) }
    return finder.changes(window: window)
  }
}
