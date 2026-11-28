//
//  ArchiveReport.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation

/// What is wrong in the newest snapshot, as RFC 0005 finds it: the data to fix in Music. It is made
/// from the snapshot alone. The `findings` table of an archive is a history, because a finding is
/// written when it is first seen and is kept after the data is fixed, so it cannot say what is wrong
/// now.
struct ArchiveReport: Sendable {
  struct Section: Sendable {
    let title: String
    let lines: [String]
  }

  let tag: String
  /// The music tracks of the snapshot, which are the ones that are archived.
  let trackCount: Int
  let sections: [Section]

  init(tag: String, tracks: [Track]) {
    let music = tracks.filter(\.isSQLEncodable)
    let reduction = CatalogReduction(Tag(tag: tag, item: music))
    let names = Dictionary(
      reduction.entries.map { ($0.persistentID, $0) }, uniquingKeysWith: { first, _ in first })

    var sections = [Section]()

    // Tracks that lack a required number, by album. Several artists on one album are one line.
    let invalid = Dictionary(grouping: reduction.invalid) {
      "\($0.album) (no \($0.missing.joined(separator: ", ")))"
    }
    var invalidLines = [String: Int]()
    for (key, tracks) in invalid {
      let artists = Set(tracks.map(\.artist))
      let artist = artists.count == 1 ? artists.first ?? "" : "\(artists.count) artists"
      invalidLines["\(artist) — \(key)"] = tracks.count
    }
    sections.append(
      Section(
        title: "Tracks with no year, track count, track number or duration",
        lines: Self.countLines(invalidLines, total: reduction.invalid.count)))

    sections.append(
      Section(
        title: "Persistent IDs that two library entries have",
        lines: reduction.findings.filter { $0.code == .duplicatePersistentID }.map {
          "\($0.persistentID.map(String.init) ?? ""): \($0.detail)"
        }))

    // Compilations that get the owner `Various Artists`. A track that is not valid is counted.
    let compilations = reduction.entries.filter { $0.albumOwner.isCompilationFallback }
    let byAlbum = Dictionary(grouping: compilations, by: { $0.album ?? "" })
    sections.append(
      Section(
        title: "Compilations with no Album Artist",
        lines: Self.countLines(byAlbum.mapValues(\.count), total: compilations.count)))

    // Albums that would be several albums. A track that is not valid has no track count to compare.
    sections.append(
      Section(
        title: "Albums that split into several albums",
        lines: reduction.tracks.albumSplitFindings.flatMap { finding in
          [finding.detail]
            + finding.related.compactMap { id in
              names[id].map {
                "  \"\($0.name)\" by \($0.artistName?.name ?? "") [\(id)]"
              }
            }
        }))

    // Sort names, for every track including the ones that are not valid.
    var sortFindings = [CatalogFinding]()
    _ = CatalogReduction.fillSortNames(reduction.entries, findings: &sortFindings)
    sections.append(
      Section(
        title: "Artists with a sort name on only some tracks",
        lines: sortFindings.sorted { $0.detail < $1.detail }.map {
          "\($0.code.rawValue): \($0.detail)"
        }))

    self.tag = tag
    self.trackCount = music.count
    self.sections = sections
  }

  /// One line for each group, the biggest first, and the total as the first line.
  private static func countLines(_ counts: [String: Int], total: Int) -> [String] {
    guard total > 0 else { return [] }
    return ["\(total) track(s) in \(counts.count) group(s)"]
      + counts.sorted { ($1.value, $0.key) < ($0.value, $1.key) }.map {
        "\($0.value)  \($0.key)"
      }
  }

  var text: String {
    var lines = ["Snapshot \(tag): \(trackCount) music tracks."]
    for section in sections {
      lines.append("")
      lines.append(section.lines.isEmpty ? "\(section.title): none" : "\(section.title):")
      lines += section.lines.map { "  \($0)" }
    }
    return lines.joined(separator: "\n")
  }
}
