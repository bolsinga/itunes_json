//
//  AlbumOwner.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation

/// The reserved artist that owns a compilation that has no Album Artist.
let variousArtistsName = "Various Artists"

/// The artist an album belongs to. See RFC 0005, "Catalog rules".
struct AlbumOwner: Hashable, Sendable {
  let name: SortableName
  /// The owner is `Various Artists` because the track is a compilation with no Album Artist.
  let isCompilationFallback: Bool
}

extension Track {
  /// In order: the non-empty Album Artist, `Various Artists` for a compilation, the track's artist.
  var albumOwner: AlbumOwner {
    if let albumArtist, !albumArtist.isEmpty {
      return AlbumOwner(
        name: SortableName(name: albumArtist, sorted: sortAlbumArtist ?? ""),
        isCompilationFallback: false)
    }
    if albumIsCompilation == 1 {
      return AlbumOwner(name: SortableName(name: variousArtistsName), isCompilationFallback: true)
    }
    return AlbumOwner(name: artistName ?? SortableName(), isCompilationFallback: false)
  }

  var albumIdentity: AlbumIdentity {
    AlbumIdentity(
      owner: albumOwner.name.name, name: album ?? "", trackCount: trackCount.positive ?? 0,
      discCount: albumDiscCount, discNumber: albumDiscNumber, compilation: albumIsCompilation == 1)
  }
}

/// One album row: each disc is its own album.
struct AlbumIdentity: Hashable, Sendable {
  let owner: String
  let name: String
  let trackCount: Int
  let discCount: Int
  let discNumber: Int
  let compilation: Bool
}

enum AlbumFindingCode: String, Sendable {
  case compilationNoAlbumArtist
  case albumSplit
}

struct AlbumFinding: Equatable, Sendable {
  let persistentID: UInt?
  let code: AlbumFindingCode
  let detail: String
  /// The tracks that the finding is about besides `persistentID`. For a split album, the tracks
  /// that are not in the most common variant.
  var related: [UInt] = []
}

enum AlbumSplitReason: String, Comparable, Sendable {
  case sameOwnerDiffers
  case compilationOwnersDiffer

  static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

private struct AlbumGroupKey: Hashable {
  let name: String
  let discNumber: Int
}

extension AlbumIdentity {
  fileprivate var sortKey: [String] {
    [owner, String(trackCount), String(discCount), String(compilation)]
  }
}

extension Array where Element == Track {
  /// One finding for each compilation track that gets its owner from the fallback, by persistent ID.
  var compilationNoAlbumArtistFindings: [AlbumFinding] {
    filter { $0.albumOwner.isCompilationFallback }
      .sorted { $0.persistentID < $1.persistentID }
      .map {
        AlbumFinding(
          persistentID: $0.persistentID, code: .compilationNoAlbumArtist,
          detail: "album=\($0.album ?? "") owner=\(variousArtistsName)")
      }
  }

  /// One finding for each album name and disc number that would become more than one album row
  /// for a reason in `AlbumSplitReason`.
  var albumSplitFindings: [AlbumFinding] {
    let groups = Dictionary(grouping: self) {
      AlbumGroupKey(name: $0.album ?? "", discNumber: $0.albumDiscNumber)
    }
    return groups.keys.sorted { ($0.name, $0.discNumber) < ($1.name, $1.discNumber) }
      .compactMap { key in
        let tracks = groups[key] ?? []
        let counts = tracks.reduce(into: [AlbumIdentity: Int]()) {
          $0[$1.albumIdentity, default: 0] += 1
        }
        guard counts.count > 1 else { return nil }

        var reasons = Set<AlbumSplitReason>()
        let byOwner = Dictionary(grouping: counts.keys, by: \.owner)
        if byOwner.values.contains(where: { $0.count > 1 }) { reasons.insert(.sameOwnerDiffers) }
        if byOwner.count > 1 && counts.keys.contains(where: \.compilation) {
          reasons.insert(.compilationOwnersDiffer)
        }
        guard !reasons.isEmpty else { return nil }

        let variants = counts.sorted { lhs, rhs in
          if lhs.value != rhs.value { return lhs.value > rhs.value }
          return lhs.key.sortKey.lexicographicallyPrecedes(rhs.key.sortKey)
        }
        let common = variants[0].key
        let outliers = tracks.filter { $0.albumIdentity != common }.map(\.persistentID).sorted()
        let variantText = variants.map {
          "(owner=\($0.key.owner) trackCount=\($0.key.trackCount) discCount=\($0.key.discCount) compilation=\($0.key.compilation) tracks=\($0.value))"
        }.joined(separator: " ")
        let reasonText = reasons.sorted().map(\.rawValue).joined(separator: ",")
        let outlierText = outliers.map(String.init).joined(separator: ",")
        return AlbumFinding(
          persistentID: nil, code: .albumSplit,
          detail:
            "album=\(key.name) discNumber=\(key.discNumber) reasons=\(reasonText) variants=\(variantText) outliers=\(outlierText)",
          related: outliers
        )
      }
  }
}
