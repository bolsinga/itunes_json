//
//  AlbumOwnerTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation
import Testing

@testable import iTunes

struct AlbumOwnerTests {
  private func track(
    id: UInt, album: String = "Album", artist: String? = "Artist", albumArtist: String? = nil,
    sortAlbumArtist: String? = nil, compilation: Bool? = nil, trackCount: Int = 2,
    discCount: Int = 1, discNumber: Int = 1
  ) -> Track {
    Track(
      album: album, albumArtist: albumArtist, artist: artist, compilation: compilation,
      discCount: discCount, discNumber: discNumber, name: "Song \(id)", persistentID: id,
      sortAlbumArtist: sortAlbumArtist, trackCount: trackCount)
  }

  @Test func albumArtistOwns() {
    let owner = track(
      id: 1, albumArtist: "Band", sortAlbumArtist: "Band, The", compilation: true
    ).albumOwner
    #expect(owner.name == SortableName(name: "Band", sorted: "Band, The"))
    #expect(!owner.isCompilationFallback)
  }

  @Test func emptyAlbumArtistIsIgnored() {
    let owner = track(id: 1, albumArtist: "").albumOwner
    #expect(owner.name.name == "Artist")
    #expect(!owner.isCompilationFallback)
  }

  @Test func compilationFallback() {
    let owner = track(id: 1, compilation: true).albumOwner
    #expect(owner.name.name == "Various Artists")
    #expect(owner.isCompilationFallback)
  }

  @Test func trackArtistOwns() {
    let owner = track(id: 1, artist: nil, albumArtist: nil).albumOwner
    #expect(owner.name == SortableName())
    #expect(track(id: 2).albumOwner.name.name == "Artist")
    #expect(!track(id: 2).albumOwner.isCompilationFallback)
  }

  @Test func variousArtistsAlbumArtistMatchesFallback() {
    let explicit = track(id: 1, albumArtist: "Various Artists", compilation: true)
    let fallback = track(id: 2, compilation: true)
    #expect(explicit.albumIdentity == fallback.albumIdentity)
    #expect(!explicit.albumOwner.isCompilationFallback)
    #expect([explicit, fallback].compilationNoAlbumArtistFindings.map(\.persistentID) == [2])
    #expect([explicit, fallback].albumSplitFindings.isEmpty)
  }

  @Test func compilationFindingPerTrack() {
    let tracks = [
      track(id: 9, compilation: true), track(id: 3, compilation: true), track(id: 5),
    ]
    let findings = tracks.compilationNoAlbumArtistFindings
    #expect(findings.map(\.persistentID) == [3, 9])
    #expect(findings.allSatisfy { $0.code == .compilationNoAlbumArtist })
  }

  @Test func partialAlbumArtistCompilationSplits() {
    let tracks = [
      track(id: 1, artist: "A", albumArtist: "Various Artists", compilation: true),
      track(id: 2, artist: "B", compilation: true),
      track(id: 3, artist: "C", albumArtist: "Compilers", compilation: true),
    ]
    let findings = tracks.albumSplitFindings
    #expect(findings.count == 1)
    #expect(findings[0].code == .albumSplit)
    #expect(findings[0].persistentID == nil)
    #expect(findings[0].detail.contains("reasons=compilationOwnersDiffer"))
  }

  @Test func countDisagreementSplits() {
    let tracks = [
      track(id: 1), track(id: 2), track(id: 3, trackCount: 3), track(id: 4, discCount: 2),
      track(id: 5, compilation: false),
    ]
    let findings = tracks.albumSplitFindings
    #expect(findings.count == 1)
    let detail = findings[0].detail
    #expect(detail.contains("album=Album discNumber=1 reasons=sameOwnerDiffers"))
    #expect(detail.contains("(owner=Artist trackCount=2 discCount=1 compilation=false tracks=3)"))
    #expect(detail.contains("(owner=Artist trackCount=3 discCount=1 compilation=false tracks=1)"))
    #expect(detail.contains("(owner=Artist trackCount=2 discCount=2 compilation=false tracks=1)"))
    #expect(detail.hasSuffix("outliers=3,4"))
  }

  @Test func compilationFlagDifferenceSplits() {
    let tracks = [track(id: 1), track(id: 2, albumArtist: "Artist", compilation: true)]
    let findings = tracks.albumSplitFindings
    #expect(findings.count == 1)
    #expect(findings[0].detail.contains("reasons=sameOwnerDiffers"))
    #expect(findings[0].detail.hasSuffix("outliers=2"))
  }

  @Test func tieBreakIsDeterministic() {
    let tracks = [track(id: 1), track(id: 2, trackCount: 3)]
    #expect(tracks.albumSplitFindings == tracks.reversed().albumSplitFindings)
    #expect(tracks.albumSplitFindings[0].detail.hasSuffix("outliers=2"))
  }

  @Test func sameNameDifferentArtistsIsNotSplit() {
    let tracks = [track(id: 1, artist: "A"), track(id: 2, artist: "B")]
    #expect(tracks.albumSplitFindings.isEmpty)
    #expect(Set(tracks.map(\.albumIdentity)).count == 2)
  }

  @Test func discsAreSeparateAlbumsWithoutSplit() {
    let tracks = [
      track(id: 1, discCount: 2, discNumber: 1), track(id: 2, discCount: 2, discNumber: 2),
    ]
    #expect(Set(tracks.map(\.albumIdentity)).count == 2)
    #expect(tracks.albumSplitFindings.isEmpty)
  }

  @Test func findingsAreOrdered() {
    let tracks = [
      track(id: 1, album: "B"), track(id: 2, album: "B", trackCount: 3),
      track(id: 3, album: "A"), track(id: 4, album: "A", trackCount: 3),
    ]
    #expect(
      tracks.albumSplitFindings.map { String($0.detail.prefix(7)) } == ["album=A", "album=B"])
  }
}
