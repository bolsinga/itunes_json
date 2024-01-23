//
//  Track+OffsetDate.swift
//
//
//  Created by Greg Bolsinga on 12/23/23.
//

import Foundation

extension Double {
  // "2004-02-04T23:32:22Z"
  static var timeIntervalSince1970ValidSentinel: Double { Double(1_075_937_542) }
}

extension Array where Element == Track {
  var datesAreAheadOneHour: Bool {
    for track in self {
      if track.datesAreAheadOneHour {
        return true
      }
    }
    return false
  }
}

extension Track {
  var isValidDateCheckSentinel: Bool {
    // "Yesterday" by Chet Atkins has not been played since before this data has been saved.
    persistentID == 17_859_820_717_873_205_520
  }

  private var playDateUTCIsSentinelDate: Bool {
    playDateUTC?.timeIntervalSince1970 == Double.timeIntervalSince1970ValidSentinel
  }

  var datesAreAheadOneHour: Bool {
    isValidDateCheckSentinel && !playDateUTCIsSentinelDate
  }

  func moveDatesBackOneHour() -> Track {
    let calendar = Calendar.autoupdatingCurrent

    let cDateAdded: Date? = {
      guard let dateAdded else { return nil }
      return calendar.date(byAdding: .hour, value: -1, to: dateAdded)
    }()
    let cPlayDate: Date? = {
      guard let playDateUTC else { return nil }
      return calendar.date(byAdding: .hour, value: -1, to: playDateUTC)
    }()
    let cReleaseDate: Date? = {
      //      guard let releaseDate else { return nil }
      //      return calendar.date(byAdding: .hour, value: -1, to: releaseDate)
      /// Strangely, the releaseDate does not seem to be offset.
      releaseDate
    }()
    let cSkipDate: Date? = {
      guard let skipDate else { return nil }
      return calendar.date(byAdding: .hour, value: -1, to: skipDate)
    }()

    return Track(
      album: album, albumArtist: albumArtist, albumRating: albumRating,
      albumRatingComputed: albumRatingComputed, artist: artist, bitRate: bitRate, bPM: bPM,
      comments: comments, compilation: compilation, composer: composer,
      contentRating: contentRating, dateAdded: cDateAdded, dateModified: dateModified,
      disabled: disabled, discCount: discCount, discNumber: discNumber, episode: episode,
      episodeOrder: episodeOrder, explicit: explicit, genre: genre, grouping: grouping,
      hasVideo: hasVideo, hD: hD, kind: kind, location: location, movie: movie,
      musicVideo: musicVideo, name: name, partOfGaplessAlbum: partOfGaplessAlbum,
      persistentID: persistentID, playCount: playCount, playDateUTC: cPlayDate,
      podcast: podcast, protected: protected, purchased: purchased, rating: rating,
      ratingComputed: ratingComputed, releaseDate: cReleaseDate, sampleRate: sampleRate,
      season: season, series: series, size: size, skipCount: skipCount, skipDate: cSkipDate,
      sortAlbum: sortAlbum, sortAlbumArtist: sortAlbumArtist, sortArtist: sortArtist,
      sortComposer: sortComposer, sortName: sortName, sortSeries: sortSeries,
      totalTime: totalTime, trackCount: trackCount, trackNumber: trackNumber,
      trackType: trackType, tVShow: tVShow, unplayed: unplayed, videoHeight: videoHeight,
      videoWidth: videoWidth, year: year)
  }
}
