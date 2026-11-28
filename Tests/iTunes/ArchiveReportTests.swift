//
//  ArchiveReportTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation
import Testing

@testable import iTunes

struct ArchiveReportTests {
  private func track(
    id: UInt, name: String = "Song", album: String = "Album", albumArtist: String? = nil,
    artist: String? = "Artist", compilation: Bool? = nil,
    dateAdded: String? = "2020-01-01T00:00:00Z",
    podcast: Bool? = nil, size: UInt64? = 100, sortArtist: String? = nil, trackCount: Int? = 2,
    year: Int? = 2000
  ) -> Track {
    Track(
      album: album, albumArtist: albumArtist, artist: artist, compilation: compilation,
      dateAdded: dateAdded, name: name, persistentID: id, podcast: podcast, size: size,
      sortArtist: sortArtist, totalTime: 1000, trackCount: trackCount, trackNumber: 1, year: year)
  }

  private func section(_ report: ArchiveReport, _ title: String) -> [String] {
    report.sections.first { $0.title.hasPrefix(title) }?.lines ?? ["no section \(title)"]
  }

  @Test func aCleanSnapshotHasNothingToFix() {
    let report = ArchiveReport(tag: "t", tracks: [track(id: 1), track(id: 2, name: "Other")])
    #expect(report.trackCount == 2)
    #expect(report.sections.allSatisfy { $0.lines.isEmpty })
    #expect(report.text.contains("Snapshot t: 2 music tracks."))
    #expect(report.text.contains("Compilations with no Album Artist: none"))
  }

  @Test func tracksThatAreNotMusicAreNotCounted() {
    let report = ArchiveReport(tag: "t", tracks: [track(id: 1), track(id: 2, podcast: true)])
    #expect(report.trackCount == 1)
  }

  @Test func invalidTracksAreGroupedByAlbum() {
    let report = ArchiveReport(
      tag: "t",
      tracks: [
        track(id: 1, album: "Comp", artist: "A", year: 0),
        track(id: 2, album: "Comp", artist: "B", year: 0),
        track(id: 3, album: "Solo", artist: "C", trackCount: nil),
        track(id: 4, album: "Fine", artist: "D"),
      ])
    #expect(
      section(report, "Tracks with no")
        == [
          "3 track(s) in 2 group(s)", "2  2 artists — Comp (no year)",
          "1  C — Solo (no track count)",
        ]
    )
  }

  @Test func duplicatePersistentIDIsListed() {
    let report = ArchiveReport(
      tag: "t",
      tracks: [
        track(id: 7, name: "One", dateAdded: "2019-01-01T00:00:00Z"),
        track(id: 7, name: "Two", dateAdded: "2021-01-01T00:00:00Z"),
      ])
    let lines = section(report, "Persistent IDs")
    #expect(lines.count == 1)
    #expect(lines[0].hasPrefix("7: dropped"))
  }

  @Test func compilationsWithNoAlbumArtistAreCountedByAlbumAndIncludeInvalidTracks() {
    let report = ArchiveReport(
      tag: "t",
      tracks: [
        track(id: 1, album: "Hits", artist: "A", compilation: true),
        track(id: 2, album: "Hits", artist: "B", compilation: true, year: 0),
        track(id: 3, album: "Mix", artist: "C", compilation: true),
        track(
          id: 4, album: "Owned", albumArtist: "Various Artists", artist: "D", compilation: true),
      ])
    #expect(
      section(report, "Compilations") == ["3 track(s) in 2 group(s)", "2  Hits", "1  Mix"])
  }

  @Test func splitAlbumNamesTheTracksThatAreNotLikeTheRest() {
    let report = ArchiveReport(
      tag: "t",
      tracks: [
        track(id: 1, name: "One", album: "Split", trackCount: 3),
        track(id: 2, name: "Two", album: "Split", trackCount: 3),
        track(id: 3, name: "Odd", album: "Split", trackCount: 1),
      ])
    let lines = section(report, "Albums that split")
    #expect(lines.count == 2)
    #expect(lines[0].hasPrefix("album=Split discNumber=1 reasons=sameOwnerDiffers"))
    #expect(lines[1] == "  \"Odd\" by Artist [3]")
  }

  @Test func sortNamesThatAreOnSomeTracksAreListedIncludingInvalidTracks() {
    let report = ArchiveReport(
      tag: "t",
      tracks: [
        track(id: 1, artist: "X", sortArtist: "X, The"),
        track(id: 2, name: "Other", artist: "X", year: 0),
      ])
    let lines = section(report, "Artists with a sort name")
    #expect(lines.count == 1)
    #expect(lines[0].hasPrefix("sortNameFilled: artist \"X\""))
  }

  @Test func theFindingOfAnInvalidTrackSaysWhereToLookInMusic() {
    let reduction = CatalogReduction(
      iTunes.Tag(
        tag: "t", item: [track(id: 1, name: "Name", album: "Album", artist: "Artist", year: 0)]))
    #expect(
      reduction.findings.map(\.detail) == ["\"Name\" by Artist on \"Album\" has no year"])
  }
}
