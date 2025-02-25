//
//  Track+DatabaseRow.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/24/25.
//

import Foundation

extension DatabaseRowLookup {
  fileprivate var itunesid: UInt? { if let v = string("itunesid") { UInt(v) } else { nil } }
  fileprivate var name: String? { string("name") }
  fileprivate var sortname: String? { string("sortname") }
  fileprivate var artist: String? { string("artist") }
  fileprivate var sortartist: String? { string("sortartist") }
  fileprivate var album: String? { string("album") }
  fileprivate var sortalbum: String? { string("sortalbum") }
  fileprivate var tracknumber: Int? { integer("tracknumber") }
  fileprivate var trackcount: Int? { integer("trackcount") }
  fileprivate var disccount: Int? { integer("disccount") }
  fileprivate var discnumber: Int? { integer("discnumber") }
  fileprivate var year: Int? { integer("year") }
  fileprivate var duration: Int? { integer("duration") }
  fileprivate var dateadded: Date? { date("dateadded") }
  fileprivate var compilation: Bool? { boolean("compilation") }
  fileprivate var composer: String? { string("composer") }
  fileprivate var datereleased: Date? { date("datereleased") }
  fileprivate var comments: String? { string("comments") }
  fileprivate var playdate: Date? { date("playdate") }
  fileprivate var delta: Int? { integer("delta") }
}

extension Track {
  init?(row: Database.Row) {
    let rowLookup = DatabaseRowLookup(row: row)

    guard let name = rowLookup.name else { return nil }
    guard let itunesid = rowLookup.itunesid else { return nil }

    self.init(
      album: rowLookup.album,
      albumArtist: nil,
      albumRating: nil,
      albumRatingComputed: nil,
      artist: rowLookup.artist,
      bitRate: nil,
      bPM: nil,
      comments: rowLookup.comments,
      compilation: rowLookup.compilation,
      composer: rowLookup.composer,
      contentRating: nil,
      dateAdded: rowLookup.dateadded,
      dateModified: nil,
      disabled: nil,
      discCount: rowLookup.disccount,
      discNumber: rowLookup.discnumber,
      episode: nil,
      episodeOrder: nil,
      explicit: nil,
      genre: nil,
      grouping: nil,
      hasVideo: nil,
      hD: nil,
      kind: nil,
      location: nil,
      movie: nil,
      musicVideo: nil,
      name: name,
      partOfGaplessAlbum: nil,
      persistentID: itunesid,
      playCount: rowLookup.delta,
      playDateUTC: rowLookup.playdate,
      podcast: nil,
      protected: nil,
      purchased: nil,
      rating: nil,
      ratingComputed: nil,
      releaseDate: rowLookup.datereleased,
      sampleRate: nil,
      season: nil,
      series: nil,
      size: nil,
      skipCount: nil,
      skipDate: nil,
      sortAlbum: rowLookup.sortalbum,
      sortAlbumArtist: nil,
      sortArtist: rowLookup.sortartist,
      sortComposer: nil,
      sortName: rowLookup.sortname,
      sortSeries: nil,
      totalTime: rowLookup.duration,
      trackCount: rowLookup.trackcount,
      trackNumber: rowLookup.tracknumber,
      trackType: nil,
      tVShow: nil,
      unplayed: nil,
      videoHeight: nil,
      videoWidth: nil,
      year: rowLookup.year,
      isrc: nil)
  }
}
