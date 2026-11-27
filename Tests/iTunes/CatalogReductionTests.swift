//
//  CatalogReductionTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation
import Testing

@testable import iTunes

struct CatalogReductionTests {
  private func track(
    id: UInt, name: String = "Song", artist: String? = "Artist", sortArtist: String? = nil,
    dateAdded: String? = "2020-01-01T00:00:00Z", size: UInt64? = 100, trackNumber: Int? = 1,
    trackCount: Int? = 2, year: Int? = 2000, totalTime: Int? = 1000
  ) -> Track {
    Track(
      album: "Album", artist: artist, dateAdded: dateAdded, name: name, persistentID: id,
      size: size, sortArtist: sortArtist, totalTime: totalTime, trackCount: trackCount,
      trackNumber: trackNumber, year: year)
  }

  private func reduce(_ tracks: [Track]) -> CatalogReduction {
    CatalogReduction(Tag(tag: "tag", item: tracks))
  }

  @Test func validTracksAreKeptInPersistentIDOrder() {
    let result = reduce([track(id: 3), track(id: 1), track(id: 2)])
    #expect(result.tag == "tag")
    #expect(result.tracks.map(\.persistentID) == [1, 2, 3])
    #expect(result.invalid.isEmpty)
    #expect(result.findings.isEmpty)
  }

  // MARK: Duplicate persistent IDs

  @Test func duplicateKeepsEarliestDateAdded() {
    let result = reduce([
      track(id: 1, name: "Later", dateAdded: "2021-01-01T00:00:00Z", size: 1),
      track(id: 1, name: "Earlier", dateAdded: "2020-01-01T00:00:00Z", size: 999),
    ])
    #expect(result.tracks.map(\.name) == ["Earlier"])
    #expect(result.findings.map(\.code) == [.duplicatePersistentID])
    #expect(result.findings.first?.persistentID == 1)
    #expect(result.findings.first?.detail.contains("dropped \"Later\"") == true)
  }

  @Test func duplicateWithSameDateKeepsSmallestSize() {
    let result = reduce([
      track(id: 1, name: "Big", size: 500),
      track(id: 1, name: "Small", size: 200),
    ])
    #expect(result.tracks.map(\.name) == ["Small"])
  }

  @Test func duplicateDatesCompareAsInstantsNotText() {
    // 12:00 at +05:00 is 07:00Z, which is earlier than 10:00Z although it sorts later as text.
    let result = reduce([
      track(id: 1, name: "Utc", dateAdded: "2020-01-01T10:00:00Z"),
      track(id: 1, name: "Offset", dateAdded: "2020-01-01T12:00:00+05:00"),
    ])
    #expect(result.tracks.map(\.name) == ["Offset"])
  }

  @Test func duplicateMissingDateAndSizeLoseToPresentOnes() {
    let result = reduce([
      track(id: 1, name: "None", dateAdded: nil, size: nil),
      track(id: 1, name: "Some", dateAdded: "2020-01-01T00:00:00Z", size: 100),
    ])
    #expect(result.tracks.map(\.name) == ["Some"])
  }

  @Test func duplicateThatTiesKeepsTheFirst() {
    let result = reduce([track(id: 1, name: "First"), track(id: 1, name: "Second")])
    #expect(result.tracks.map(\.name) == ["First"])
    #expect(result.findings.count == 1)
  }

  @Test func duplicateEntriesThatDifferInAttributesKeepTheWinnersValues() {
    let result = reduce([
      track(id: 1, name: "Newer", dateAdded: "2021-01-01T00:00:00Z", year: 2010),
      track(id: 1, name: "Older", dateAdded: "2020-01-01T00:00:00Z", year: 1999),
    ])
    #expect(result.tracks.count == 1)
    #expect(result.tracks[0].year == 1999)
  }

  @Test func duplicateIsReducedBeforeValidity() {
    // The kept entry is invalid, so the track is invalid even though the dropped one is complete.
    let result = reduce([
      track(id: 1, name: "Early", dateAdded: "2020-01-01T00:00:00Z", year: 0),
      track(id: 1, name: "Late", dateAdded: "2021-01-01T00:00:00Z"),
    ])
    #expect(result.tracks.isEmpty)
    #expect(result.invalid.map(\.persistentID) == [1])
    #expect(result.findings.map(\.code) == [.invalidTrack, .duplicatePersistentID])
  }

  @Test func threeEntriesGiveTwoFindings() {
    let result = reduce([
      track(id: 1, size: 30), track(id: 1, size: 10), track(id: 1, size: 20),
    ])
    #expect(result.tracks.first?.size == 10)
    #expect(result.findings.map(\.code) == [.duplicatePersistentID, .duplicatePersistentID])
  }

  // MARK: Invalid tracks

  @Test(arguments: [
    ("track number", track0(trackNumber: nil)),
    ("track number", track0(trackNumber: 0)),
    ("track count", track0(trackCount: nil)),
    ("track count", track0(trackCount: -1)),
    ("year", track0(year: 0)),
    ("year", track0(year: nil)),
    ("duration", track0(totalTime: 0)),
  ])
  func missingNumberExcludesTrack(field: String, track: Track) {
    let result = reduce([track])
    #expect(result.tracks.isEmpty)
    #expect(
      result.invalid == [InvalidCatalogTrack(persistentID: 0, name: "Song", missing: [field])])
    #expect(result.findings.count == 1)
    #expect(result.findings[0].code == .invalidTrack)
    #expect(result.findings[0].persistentID == 0)
    #expect(result.findings[0].detail.contains(field))
  }

  private static func track0(
    trackNumber: Int? = 1, trackCount: Int? = 2, year: Int? = 2000, totalTime: Int? = 1000
  ) -> Track {
    Track(
      name: "Song", persistentID: 0, totalTime: totalTime, trackCount: trackCount,
      trackNumber: trackNumber, year: year)
  }

  @Test func invalidTrackNamesEverythingMissing() {
    let result = reduce([track(id: 5, trackCount: nil, year: 0)])
    #expect(result.invalid.first?.missing == ["track count", "year"])
    #expect(result.findings.first?.detail.contains("track count, year") == true)
  }

  @Test func invalidTrackDoesNotRemoveValidOnes() {
    let result = reduce([track(id: 1), track(id: 2, year: 0), track(id: 3)])
    #expect(result.tracks.map(\.persistentID) == [1, 3])
    #expect(result.invalid.map(\.persistentID) == [2])
  }

  // MARK: Newest valid value

  @Test func newestValidTakesEachAttributeFromTheNewestSnapshotWithIt() {
    let merged = CatalogAttributes.newestValid(oldestFirst: [
      CatalogAttributes(trackNumber: 1, trackCount: 10, year: 1999, duration: 100),
      CatalogAttributes(trackNumber: 2, trackCount: 12, year: 0, duration: 200),
      CatalogAttributes(trackNumber: 3, trackCount: nil, year: nil, duration: 0),
    ])
    #expect(merged == CatalogAttributes(trackNumber: 3, trackCount: 12, year: 1999, duration: 200))
  }

  @Test func newestValidIsNilForAnAttributeThatIsNeverValid() {
    let merged = CatalogAttributes.newestValid(oldestFirst: [
      CatalogAttributes(trackNumber: 1, trackCount: nil, year: 0, duration: 100),
      CatalogAttributes(trackNumber: 1, trackCount: -1, year: nil, duration: 100),
    ])
    #expect(merged.trackCount == nil)
    #expect(merged.year == nil)
    #expect(merged.trackNumber == 1)
  }

  @Test func newestValidOfNothingIsEmpty() {
    #expect(CatalogAttributes.newestValid(oldestFirst: []) == CatalogAttributes())
  }

  @Test func attributesComeFromATrack() {
    #expect(
      CatalogAttributes(track(id: 1, year: 0))
        == CatalogAttributes(trackNumber: 1, trackCount: 2, year: nil, duration: 1000))
  }

  // MARK: Sort names

  @Test func sortNameIsFilledForTracksWithoutOne() {
    // Neil Young: the sort name was set on some tracks before the others.
    let result = reduce([
      track(id: 1, artist: "Neil Young", sortArtist: "Young, Neil"),
      track(id: 2, artist: "Neil Young"),
      track(id: 3, artist: "Neil Young", sortArtist: ""),
      track(id: 4, artist: "Neil Young", sortArtist: "Young, Neil"),
    ])
    #expect(result.tracks.map(\.sortArtist) == Array(repeating: "Young, Neil", count: 4))
    #expect(result.findings.count == 1)
    #expect(result.findings[0].code == .sortNameFilled)
    #expect(result.findings[0].persistentID == nil)
    #expect(result.findings[0].detail.contains("Neil Young"))
    #expect(result.findings[0].detail.contains("\"Young, Neil\""))
    #expect(result.findings[0].detail.contains("2 with it and 2 without"))
  }

  @Test func sortNameFromAlbumArtistCounts() {
    var withAlbumArtist = track(id: 1, artist: nil)
    withAlbumArtist.albumArtist = "Neil Young"
    withAlbumArtist.sortAlbumArtist = "Young, Neil"
    let result = reduce([withAlbumArtist, track(id: 2, artist: "Neil Young")])
    #expect(result.tracks.map(\.artistName?.sorted) == ["Young, Neil", "Young, Neil"])
    #expect(result.findings.map(\.code) == [.sortNameFilled])
  }

  @Test func allTracksWithTheSortNameGiveNoFinding() {
    let result = reduce([
      track(id: 1, artist: "Neil Young", sortArtist: "Young, Neil"),
      track(id: 2, artist: "Neil Young", sortArtist: "Young, Neil"),
    ])
    #expect(result.findings.isEmpty)
  }

  @Test func noTrackWithASortNameGivesNoFinding() {
    let result = reduce([track(id: 1), track(id: 2)])
    #expect(result.findings.isEmpty)
    #expect(result.tracks.allSatisfy { $0.sortArtist == nil })
  }

  @Test func sortNameDoesNotLeakToOtherArtists() {
    let result = reduce([
      track(id: 1, artist: "Neil Young", sortArtist: "Young, Neil"),
      track(id: 2, artist: "Other"),
    ])
    #expect(result.tracks[1].sortArtist == nil)
    #expect(result.findings.isEmpty)
  }

  @Test func conflictUsesTheMostCommonSortName() {
    let result = reduce([
      track(id: 1, sortArtist: "B"), track(id: 2, sortArtist: "A"), track(id: 3, sortArtist: "B"),
    ])
    #expect(result.tracks.map(\.sortArtist) == ["B", "B", "B"])
    #expect(result.findings.map(\.code) == [.sortNameConflict])
    #expect(result.findings[0].detail.contains("used \"B\""))
  }

  @Test func conflictTieUsesTheFirstAlphabetically() {
    let result = reduce([track(id: 1, sortArtist: "Zed"), track(id: 2, sortArtist: "Abe")])
    #expect(result.tracks.map(\.sortArtist) == ["Abe", "Abe"])
    #expect(result.findings[0].detail.contains("used \"Abe\""))
  }

  @Test func conflictAndFilledAreBothReported() {
    let result = reduce([
      track(id: 1, sortArtist: "B"), track(id: 2, sortArtist: "A"), track(id: 3, sortArtist: "B"),
      track(id: 4),
    ])
    #expect(result.findings.map(\.code) == [.sortNameConflict, .sortNameFilled])
    #expect(result.tracks.allSatisfy { $0.sortArtist == "B" })
  }

  @Test func sortNameOnlyOnAnInvalidTrackIsNotUsed() {
    let result = reduce([
      track(id: 1, sortArtist: "Young", year: 0), track(id: 2),
    ])
    #expect(result.tracks.map(\.sortArtist) == [nil])
    #expect(result.findings.map(\.code) == [.invalidTrack])
  }

  // MARK: Order

  @Test func outputIsTheSameForAnyInputOrder() {
    let tracks = [
      track(id: 4, artist: "N", sortArtist: "Y"), track(id: 2, year: 0), track(id: 4, size: 5),
      track(id: 1, artist: "N"), track(id: 3, artist: "N", sortArtist: "Z"),
      track(id: 5, trackCount: nil),
    ]
    let forward = reduce(tracks)
    let backward = reduce(tracks.reversed())
    #expect(forward.tracks.map(\.persistentID) == [1, 3, 4])
    #expect(forward.tracks.map(\.persistentID) == backward.tracks.map(\.persistentID))
    #expect(forward.invalid == backward.invalid)
    #expect(forward.findings.map(\.code) == backward.findings.map(\.code))
    #expect(forward.findings.map(\.persistentID) == backward.findings.map(\.persistentID))
  }

  @Test func findingsAreOrderedByCodeThenPersistentID() {
    let result = reduce([
      track(id: 9, year: 0), track(id: 3, year: 0),
      track(id: 7), track(id: 7, size: 1),
      track(id: 1, artist: "N", sortArtist: "Y"), track(id: 2, artist: "N"),
    ])
    #expect(
      result.findings.map(\.code) == [
        .invalidTrack, .invalidTrack, .duplicatePersistentID, .sortNameFilled,
      ])
    #expect(result.findings.prefix(2).map(\.persistentID) == [3, 9])
  }
}
