//
//  DatabaseRowTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/25/25.
//

import Testing

@testable import iTunes

struct DatabaseRowTests {
  var itunesid: Database.Column {
    ("itunesid", .string(String(UInt(3))))
  }

  var name: Database.Column {
    ("name", .string("song title"))
  }

  var basic: [Database.Column] {
    [itunesid, name]
  }

  func row(_ value: Database.Column) -> [Database.Column] {
    basic + [value]
  }

  @Test func itunesid() async throws {
    #expect(Track(row: basic)?.persistentID == 3)
    #expect(Track(row: [name]) == nil)
    #expect(Track(row: [name, ("itunesid", .string(""))]) == nil)
    #expect(Track(row: [name, ("itunesid", .integer(3))]) == nil)
    #expect(Track(row: [name, ("itunesid", .null)]) == nil)
  }

  @Test func name() async throws {
    #expect(Track(row: basic)?.name == "song title")
    #expect(Track(row: [itunesid]) == nil)
    #expect(Track(row: [itunesid, ("name", .string(""))]) == nil)
    #expect(Track(row: [itunesid, ("name", .integer(3))]) == nil)
    #expect(Track(row: [itunesid, ("name", .null)]) == nil)
  }

  @Test func sortname() async throws {
    #expect(Track(row: basic)?.sortName == nil)
    #expect(Track(row: row(("sortname", .string("Z"))))?.sortName == "Z")
    #expect(Track(row: row(("sortname", .string(""))))?.sortName == nil)
    #expect(Track(row: row(("sortname", .integer(3))))?.sortName == nil)
    #expect(Track(row: row(("sortname", .null)))?.sortName == nil)
  }

  @Test func artist() async throws {
    #expect(Track(row: basic)?.artist == nil)
    #expect(Track(row: row(("artist", .string("Z"))))?.artist == "Z")
    #expect(Track(row: row(("artist", .string(""))))?.artist == nil)
    #expect(Track(row: row(("artist", .integer(3))))?.artist == nil)
    #expect(Track(row: row(("artist", .null)))?.artist == nil)
  }

  @Test func sortartist() async throws {
    #expect(Track(row: basic)?.sortArtist == nil)
    #expect(Track(row: row(("sortartist", .string("Z"))))?.sortArtist == "Z")
    #expect(Track(row: row(("sortartist", .string(""))))?.sortArtist == nil)
    #expect(Track(row: row(("sortartist", .integer(3))))?.sortArtist == nil)
    #expect(Track(row: row(("sortartist", .null)))?.sortArtist == nil)
  }

  @Test func album() async throws {
    #expect(Track(row: basic)?.album == nil)
    #expect(Track(row: row(("album", .string("Z"))))?.album == "Z")
    #expect(Track(row: row(("album", .string(""))))?.album == nil)
    #expect(Track(row: row(("album", .integer(3))))?.album == nil)
    #expect(Track(row: row(("album", .null)))?.album == nil)
  }

  @Test func sortalbum() async throws {
    #expect(Track(row: basic)?.sortAlbum == nil)
    #expect(Track(row: row(("sortalbum", .string("Z"))))?.sortAlbum == "Z")
    #expect(Track(row: row(("sortalbum", .string(""))))?.sortAlbum == nil)
    #expect(Track(row: row(("sortalbum", .integer(3))))?.sortAlbum == nil)
    #expect(Track(row: row(("sortalbum", .null)))?.sortAlbum == nil)
  }

  @Test func tracknumber() async throws {
    #expect(Track(row: basic)?.trackNumber == nil)
    #expect(Track(row: row(("tracknumber", .string("Z"))))?.trackNumber == nil)
    #expect(Track(row: row(("tracknumber", .string(""))))?.trackNumber == nil)
    #expect(Track(row: row(("tracknumber", .integer(3))))?.trackNumber == 3)
    #expect(Track(row: row(("tracknumber", .null)))?.trackNumber == nil)
  }

  @Test func trackcount() async throws {
    #expect(Track(row: basic)?.trackCount == nil)
    #expect(Track(row: row(("trackcount", .string("Z"))))?.trackCount == nil)
    #expect(Track(row: row(("trackcount", .string(""))))?.trackCount == nil)
    #expect(Track(row: row(("trackcount", .integer(3))))?.trackCount == 3)
    #expect(Track(row: row(("trackcount", .null)))?.trackCount == nil)
  }

  @Test func disccount() async throws {
    #expect(Track(row: basic)?.discCount == nil)
    #expect(Track(row: row(("disccount", .string("Z"))))?.discCount == nil)
    #expect(Track(row: row(("disccount", .string(""))))?.discCount == nil)
    #expect(Track(row: row(("disccount", .integer(3))))?.discCount == 3)
    #expect(Track(row: row(("disccount", .null)))?.discCount == nil)
  }

  @Test func discnumber() async throws {
    #expect(Track(row: basic)?.discNumber == nil)
    #expect(Track(row: row(("discnumber", .string("Z"))))?.discNumber == nil)
    #expect(Track(row: row(("discnumber", .string(""))))?.discNumber == nil)
    #expect(Track(row: row(("discnumber", .integer(3))))?.discNumber == 3)
    #expect(Track(row: row(("discnumber", .null)))?.discNumber == nil)
  }

  @Test func year() async throws {
    #expect(Track(row: basic)?.year == nil)
    #expect(Track(row: row(("year", .string("Z"))))?.year == nil)
    #expect(Track(row: row(("year", .string(""))))?.year == nil)
    #expect(Track(row: row(("year", .integer(3))))?.year == 3)
    #expect(Track(row: row(("year", .null)))?.year == nil)
  }

  @Test func duration() async throws {
    #expect(Track(row: basic)?.totalTime == nil)
    #expect(Track(row: row(("duration", .string("Z"))))?.totalTime == nil)
    #expect(Track(row: row(("duration", .string(""))))?.totalTime == nil)
    #expect(Track(row: row(("duration", .integer(3))))?.totalTime == 3)
    #expect(Track(row: row(("duration", .null)))?.totalTime == nil)
  }

  @Test func dateadded() async throws {
    #expect(Track(row: basic)?.dateAdded == nil)
    #expect(Track(row: row(("dateadded", .string("Z"))))?.dateAdded == nil)
    #expect(Track(row: row(("dateadded", .string(""))))?.dateAdded == nil)
    #expect(Track(row: row(("dateadded", .integer(3))))?.dateAdded == nil)
    #expect(Track(row: row(("dateadded", .null)))?.dateAdded == nil)
    #expect(Track(row: row(("dateadded", .string("2003-12-15T17:02:56Z"))))?.dateAdded != nil)
  }

  @Test func compilation() async throws {
    #expect(Track(row: basic)?.compilation == nil)
    #expect(Track(row: row(("compilation", .string("Z"))))?.compilation == nil)
    #expect(Track(row: row(("compilation", .string(""))))?.compilation == nil)
    #expect(Track(row: row(("compilation", .integer(0))))?.compilation == nil)
    #expect(Track(row: row(("compilation", .integer(1))))?.compilation == true)
    #expect(Track(row: row(("compilation", .integer(3))))?.compilation == nil)
    #expect(Track(row: row(("compilation", .null)))?.compilation == nil)
  }

  @Test func composer() async throws {
    #expect(Track(row: basic)?.composer == nil)
    #expect(Track(row: row(("composer", .string("Z"))))?.composer == "Z")
    #expect(Track(row: row(("composer", .string(""))))?.composer == nil)
    #expect(Track(row: row(("composer", .integer(3))))?.composer == nil)
    #expect(Track(row: row(("composer", .null)))?.composer == nil)
  }

  @Test func datereleased() async throws {
    #expect(Track(row: basic)?.releaseDate == nil)
    #expect(Track(row: row(("datereleased", .string("Z"))))?.releaseDate == nil)
    #expect(Track(row: row(("datereleased", .string(""))))?.releaseDate == nil)
    #expect(Track(row: row(("datereleased", .integer(3))))?.releaseDate == nil)
    #expect(Track(row: row(("datereleased", .null)))?.releaseDate == nil)
    #expect(Track(row: row(("datereleased", .string("2003-12-15T17:02:56Z"))))?.releaseDate != nil)
  }

  @Test func comments() async throws {
    #expect(Track(row: basic)?.comments == nil)
    #expect(Track(row: row(("comments", .string("Z"))))?.comments == "Z")
    #expect(Track(row: row(("comments", .string(""))))?.comments == nil)
    #expect(Track(row: row(("comments", .integer(3))))?.comments == nil)
    #expect(Track(row: row(("comments", .null)))?.comments == nil)
  }

  @Test func playdate() async throws {
    #expect(Track(row: basic)?.playDateUTC == nil)
    #expect(Track(row: row(("playdate", .string("Z"))))?.playDateUTC == nil)
    #expect(Track(row: row(("playdate", .string(""))))?.playDateUTC == nil)
    #expect(Track(row: row(("playdate", .integer(3))))?.playDateUTC == nil)
    #expect(Track(row: row(("playdate", .null)))?.playDateUTC == nil)
    #expect(Track(row: row(("playdate", .string("2003-12-15T17:02:56Z"))))?.playDateUTC != nil)
  }

  @Test func delta() async throws {
    #expect(Track(row: basic)?.playCount == nil)
    #expect(Track(row: row(("delta", .string("Z"))))?.playCount == nil)
    #expect(Track(row: row(("delta", .string(""))))?.playCount == nil)
    #expect(Track(row: row(("delta", .integer(3))))?.playCount == 3)
    #expect(Track(row: row(("delta", .null)))?.playCount == nil)
  }
}
