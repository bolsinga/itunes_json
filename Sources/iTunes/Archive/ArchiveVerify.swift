//
//  ArchiveVerify.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/26.
//

import Foundation

/// How one table of an archive is different from the same table of a rebuild.
struct ArchiveDifference: Equatable, Sendable {
  let table: String
  /// The rows only the archive has.
  let onlyInArchive: Int
  /// The rows only the rebuild has.
  let onlyInRebuild: Int
  /// A few of those rows.
  let examples: [String]
}

struct ArchiveVerifyError: Error, CustomStringConvertible {
  let differences: [ArchiveDifference]

  var description: String {
    (["The archive is not equal to a rebuild."]
      + differences.flatMap { difference in
        [
          "\(difference.table): \(difference.onlyInArchive) row(s) only in the archive, \(difference.onlyInRebuild) only in the rebuild"
        ] + difference.examples.map { "  \($0)" }
      }).joined(separator: "\n")
  }
}

extension Database {
  /// How the tables of this archive are different from the tables of the archive at `path`, which
  /// is a rebuild from the same snapshots. Every column is compared, the ids included. An archive
  /// that is equal to its rebuild has no differences.
  func archiveDifferences(rebuiltAt path: String, examples count: Int = 3) throws
    -> [ArchiveDifference]
  {
    let attach = try prepare("ATTACH DATABASE ? AS rebuilt")
    defer { attach.close() }
    try run(attach, [.string(path)])
    defer { try? execute("DETACH DATABASE rebuilt") }

    var differences = [ArchiveDifference]()
    for (table, filter) in ArchiveSchema.comparedTables {
      let onlyInArchive =
        "SELECT * FROM main.\(table) \(filter) EXCEPT SELECT * FROM rebuilt.\(table) \(filter)"
      let onlyInRebuild =
        "SELECT * FROM rebuilt.\(table) \(filter) EXCEPT SELECT * FROM main.\(table) \(filter)"
      let archiveCount = try rowCount(onlyInArchive)
      let rebuildCount = try rowCount(onlyInRebuild)
      guard archiveCount > 0 || rebuildCount > 0 else { continue }
      let examples =
        try rowTexts("\(onlyInArchive) LIMIT \(count)").map { "archive: \($0)" }
        + rowTexts("\(onlyInRebuild) LIMIT \(count)").map { "rebuild: \($0)" }
      differences.append(
        ArchiveDifference(
          table: table, onlyInArchive: archiveCount, onlyInRebuild: rebuildCount,
          examples: examples))
    }
    return differences
  }

  private func rowCount(_ query: String) throws -> Int {
    let rows = try execute(query: "SELECT COUNT(*) FROM (\(query))", arguments: []).first ?? []
    return Int(rows.first?.first?.value.integer ?? 0)
  }

  private func rowTexts(_ query: String) throws -> [String] {
    (try execute(query: query, arguments: []).first ?? []).map {
      $0.map(\.value.description).joined(separator: " | ")
    }
  }
}
