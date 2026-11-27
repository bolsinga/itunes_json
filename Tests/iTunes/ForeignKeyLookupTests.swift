//
//  ForeignKeyLookupTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Testing

@testable import iTunes

struct ForeignKeyLookupTests {
  private var encoder: TrackRowEncoder {
    get throws {
      try [
        Track(
          album: "Album", artist: "Artist", name: "Song", persistentID: 1, totalTime: 1000,
          trackCount: 1, trackNumber: 1, year: 2000)
      ].rowEncoder(nil)
    }
  }

  // A song or album whose parent is not in the lookup is an error that names it, not a row that
  // refers to an id of -1.
  @Test func albumWithoutItsArtistThrows() throws {
    let error = try #require(throws: ForeignKeyLookupError.self) {
      _ = try encoder.albumTableBuilder(artistLookup: [:])
    }
    #expect(error.description == "The albums row Album has no artist Artist row to refer to.")
  }

  @Test func songWithoutItsArtistOrAlbumThrows() throws {
    let error = try #require(throws: ForeignKeyLookupError.self) {
      _ = try encoder.songTableBuilder(artistLookup: [:], albumLookup: [:])
    }
    #expect(error.description == "The songs row Song has no artist Artist row to refer to.")
  }
}
