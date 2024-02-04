//
//  Repair+Track.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation

extension Track {
  fileprivate var fixableAlbum: Bool {
    guard let album else { return true }
    return album.isEmpty
  }

  fileprivate var fixableYear: Bool {
    guard let year else { return true }
    return year <= 0
  }

  fileprivate var fixableTrackCount: Bool {
    guard let trackCount else { return true }
    return trackCount <= 0
  }

  fileprivate var fixableTrackNumber: Bool {
    guard let trackNumber else { return true }
    return trackNumber <= 0
  }

  func repair(_ fix: Fix) -> Track? {
    guard !fix.trackIgnored else { return nil }

    let fixedAlbum = (self.fixableAlbum ? fix.album : nil) ?? self.album
    let fixedArtist = fix.artist ?? self.artist
    let fixedPlayCount = fix.playCount ?? self.playCount
    let fixedPlayDate = fix.playDate ?? self.playDateUTC
    let fixedTrackCount = (self.fixableTrackCount ? fix.trackCount : nil) ?? self.trackCount
    let fixedTrackNumber = (self.fixableTrackNumber ? fix.trackNumber : nil) ?? self.trackNumber
    let fixedYear = (self.fixableYear ? fix.year : nil) ?? self.year

    let fixedSortArtist = {
      if let sortArtist = fix.sortArtist { return sortArtist.isEmpty ? nil : sortArtist }
      return self.sortArtist
    }()

    return Track(
      album: fixedAlbum, albumArtist: albumArtist, albumRating: albumRating,
      albumRatingComputed: albumRatingComputed, artist: fixedArtist, bitRate: bitRate, bPM: bPM,
      comments: comments, compilation: compilation, composer: composer,
      contentRating: contentRating, dateAdded: dateAdded, dateModified: dateModified,
      disabled: disabled, discCount: discCount, discNumber: discNumber, episode: episode,
      episodeOrder: episodeOrder, explicit: explicit, genre: genre, grouping: grouping,
      hasVideo: hasVideo, hD: hD, kind: fix.kind ?? kind, location: location, movie: movie,
      musicVideo: musicVideo, name: name, partOfGaplessAlbum: partOfGaplessAlbum,
      persistentID: persistentID, playCount: fixedPlayCount, playDateUTC: fixedPlayDate,
      podcast: podcast, protected: protected, purchased: purchased, rating: rating,
      ratingComputed: ratingComputed, releaseDate: releaseDate, sampleRate: sampleRate,
      season: season, series: series, size: size, skipCount: skipCount, skipDate: skipDate,
      sortAlbum: sortAlbum, sortAlbumArtist: sortAlbumArtist, sortArtist: fixedSortArtist,
      sortComposer: sortComposer, sortName: sortName, sortSeries: sortSeries,
      totalTime: totalTime, trackCount: fixedTrackCount, trackNumber: fixedTrackNumber,
      trackType: trackType, tVShow: tVShow, unplayed: unplayed, videoHeight: videoHeight,
      videoWidth: videoWidth, year: fixedYear)
  }

  internal func matches(problem: Problem) -> Bool {
    let artistMatch = {
      guard let artist = problem.artist else { return true }
      return artist == self.artist
    }()

    guard artistMatch else { return false }

    let albumMatch = {
      guard let album = problem.album else { return true }
      return album == self.album
    }()

    guard albumMatch else { return false }

    let nameMatch = {
      guard let name = problem.name else { return true }
      return name == self.name
    }()

    guard nameMatch else { return false }

    let playDateMatch = {
      guard let problemPlayDate = problem.playDate else { return true }
      guard let problemPlayCount = problem.playCount else { return true }

      guard let playDate = self.playDateUTC else { return true }
      guard let playCount = self.playCount else { return true }

      guard problemPlayCount == playCount else { return false }

      let timeInterval = abs(problemPlayDate.timeIntervalSince1970 - playDate.timeIntervalSince1970)
      return timeInterval == 0 || timeInterval == 60 * 60
    }()

    if playDateMatch { return true }

    let playDateEmptyMatch = {
      guard problem.playDate == nil, self.playDateUTC == nil else { return false }

      return problem.playCount != nil
    }()

    return playDateEmptyMatch
  }
}
