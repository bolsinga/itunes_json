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
    #expect(songArtist.artist == "Greg Bolsinga")
    #expect(songArtist.song == "The Ballad of the Coder")
  }
}
