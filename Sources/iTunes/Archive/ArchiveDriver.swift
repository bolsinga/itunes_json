//
//  ArchiveDriver.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/26.
//

import Foundation
import os

extension Logger {
  fileprivate static let archiveDriver = Logger(category: "archiveDriver")
}

/// The repository has no tag that is a snapshot.
struct GitNoSnapshots: Error, CustomStringConvertible {
  var description: String { "The repository has no snapshots." }
}

enum ArchiveRunError: Error, CustomStringConvertible {
  /// A snapshot could not be read or decoded. The archive has every snapshot before it.
  case cannotRead(tag: String, error: any Error)
  /// A snapshot could not be applied. The archive has every snapshot before it.
  case cannotApply(tag: String, error: any Error)

  var description: String {
    switch self {
    case .cannotRead(let tag, let error): "Cannot read \(tag): \(error)"
    case .cannotApply(let tag, let error): "Cannot apply \(tag): \(error)"
    }
  }
}

/// What a run did.
struct ArchiveRunSummary: Equatable, Sendable {
  /// The snapshots this run applied.
  let applied: Int
  /// The tag of the newest snapshot in the archive, if there is one.
  let lastTag: String?
  /// How many findings the whole archive has, by code.
  let findings: [String: Int]

  var text: String {
    let counts = findings.sorted { $0.key < $1.key }.map { "  \($0.key): \($0.value)" }
    return
      (["Applied \(applied) snapshot(s). Last tag: \(lastTag ?? "none")."]
      + (counts.isEmpty ? ["No findings."] : ["Findings:"] + counts)).joined(separator: "\n")
  }
}

/// Reads one value for each tag, a few at a time, and gives them in the order of the tags.
///
/// It reads when the consumer asks, so at most `window` tags are being read or are waiting, and a
/// slow consumer holds the reading back. The memory does not grow with the number of tags. A
/// failure ends the sequence after the values before it.
struct OrderedReads<T: Sendable>: AsyncSequence {
  typealias Element = Tag<T>

  let tags: [String]
  let window: Int
  let produce: @Sendable (String) async throws -> T

  func makeAsyncIterator() -> Iterator {
    Iterator(tags: tags, window: Swift.max(window, 1), produce: produce)
  }

  struct Iterator: AsyncIteratorProtocol {
    let tags: [String]
    let window: Int
    let produce: @Sendable (String) async throws -> T
    private var next = 0
    private var pending = [Task<Tag<T>, any Error>]()

    init(tags: [String], window: Int, produce: @escaping @Sendable (String) async throws -> T) {
      self.tags = tags
      self.window = window
      self.produce = produce
    }

    mutating func next() async throws -> Tag<T>? {
      while next < tags.count && pending.count < window {
        let tag = tags[next]
        let produce = self.produce
        pending.append(
          Task.detached {
            do {
              return Tag(tag: tag, item: try await produce(tag))
            } catch {
              throw ArchiveRunError.cannotRead(tag: tag, error: error)
            }
          })
        next += 1
      }
      guard !pending.isEmpty else { return nil }
      let first = pending.removeFirst()
      do {
        return try await first.value
      } catch {
        for task in pending { task.cancel() }
        pending = []
        next = tags.count
        throw error
      }
    }
  }
}

extension Database {
  /// Applies each snapshot, which are given in tag order and are all newer than what the archive
  /// has, in one transaction each. The state comes from the archive, so an empty archive is a
  /// rebuild and an archive that has snapshots is an update.
  func archiveSnapshots(
    _ snapshots: some AsyncSequence<Tag<[Track]>, any Error>,
    isOrderedBefore: @escaping @Sendable (String, String) -> Bool = TagOrder.isOrderedBefore
  ) async throws -> ArchiveRunSummary {
    try prepareArchive()
    var state = try loadArchiveState()
    var applied = 0
    for try await snapshot in snapshots {
      Logger.archiveDriver.info("\(snapshot.tag, privacy: .public)")
      do {
        try writeArchive(state.apply(snapshot), isOrderedBefore: isOrderedBefore)
      } catch {
        throw ArchiveRunError.cannotApply(tag: snapshot.tag, error: error)
      }
      applied += 1
    }
    return try archiveSummary(applied: applied)
  }

  fileprivate func archiveSummary(applied: Int) throws -> ArchiveRunSummary {
    let counts =
      try execute(
        query: "SELECT code, COUNT(*) FROM findings GROUP BY code", arguments: []
      ).first ?? []
    var findings = [String: Int]()
    for row in counts {
      guard let code = row[0].value.string, let count = row[1].value.integer else { continue }
      findings[code] = Int(count)
    }
    return ArchiveRunSummary(applied: applied, lastTag: try archiveLastTag(), findings: findings)
  }
}

extension Repository {
  /// The newest snapshot, which is the last tag in tag order.
  func newestSnapshot() async throws -> Tag<[Track]> {
    try await git.status()
    guard let tag = try await git.tags().stampOrderedMatching.last else {
      throw GitNoSnapshots()
    }
    return Tag(
      tag: tag,
      item: try Track.array(from: try await git.show(commit: tag, path: backupFile.filename)))
  }

  /// The snapshots after `tag`, if there is one, up to `last`, if there is one, in tag order. The
  /// tags are the ones `tagDatum()` reads. A few are read and decoded at once, and one is applied
  /// at a time.
  func snapshots(after tag: String?, through last: String? = nil, window: Int = 4) async throws
    -> OrderedReads<[Track]>
  {
    try await git.status()
    let tags = try await git.tags().stampOrderedMatching(after: tag, through: last)
    let git = self.git
    let filename = backupFile.filename
    return OrderedReads(tags: tags, window: window) { tag in
      try Track.array(from: try await git.show(commit: tag, path: filename))
    }
  }
}
