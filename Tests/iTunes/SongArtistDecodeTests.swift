//
//  SongArtistDecodeTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/6/25.
//

import Foundation
import Testing

@testable import iTunes

struct SongArtistDecodeTests {
  @Test func oldformat() async throws {
    let json = "{ \"artist\" : \"Greg Bolsinga\", \"song\" : \"The Ballad of the Coder\" }"
    let decoder = JSONDecoder()
    let songArtist = try decoder.decode(SongArtist.self, from: json.data(using: .utf8)!)
    #expect(songArtist.artist.name == "Greg Bolsinga")
    #expect(songArtist.artist.sorted.isEmpty)
    #expect(songArtist.song.name == "The Ballad of the Coder")
    #expect(songArtist.song.sorted.isEmpty)
  }

  @Test func newformat() async throws {
    let json =
      "{ \"artist\" : { \"name\" :\"Greg Bolsinga\", \"sorted\" :\"Bolsinga, Greg\" }, \"song\" : { \"name\" : \"The Ballad of the Coder\", \"sorted\" : \"Ballad of the Coder\" } }"

    let decoder = JSONDecoder()
    let songArtist = try decoder.decode(SongArtist.self, from: json.data(using: .utf8)!)
    #expect(songArtist.artist.name == "Greg Bolsinga")
    #expect(songArtist.artist.sorted == "Bolsinga, Greg")
    #expect(songArtist.song.name == "The Ballad of the Coder")
    #expect(songArtist.song.sorted == "Ballad of the Coder")
  }
}
