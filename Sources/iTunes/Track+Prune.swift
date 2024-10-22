//
//  Track+Prune.swift
//
//
//  Created by Greg Bolsinga on 1/19/24.
//

import Foundation

extension Track {
  var pruned: Track {
    return Track(
      album: album, albumArtist: albumArtist, albumRating: nil,
      albumRatingComputed: nil, artist: artist, bitRate: nil, bPM: nil,
      comments: comments, compilation: compilation, composer: composer,
      contentRating: nil, dateAdded: dateAdded, dateModified: nil,
      disabled: nil, discCount: discCount, discNumber: discNumber, episode: nil,
      episodeOrder: nil, explicit: nil, genre: nil, grouping: nil,
      hasVideo: nil, hD: nil, kind: nil, location: nil, movie: nil,
      musicVideo: nil, name: name, partOfGaplessAlbum: nil,
      persistentID: persistentID, playCount: playCount, playDateUTC: playDateUTC,
      podcast: nil, protected: nil, purchased: nil, rating: nil,
      ratingComputed: nil, releaseDate: releaseDate, sampleRate: nil,
      season: nil, series: nil, size: nil, skipCount: nil, skipDate: nil,
      sortAlbum: sortAlbum, sortAlbumArtist: sortAlbumArtist, sortArtist: sortArtist,
      sortComposer: nil, sortName: sortName, sortSeries: nil,
      totalTime: totalTime, trackCount: trackCount, trackNumber: trackNumber,
      trackType: nil, tVShow: nil, unplayed: nil, videoHeight: nil,
      videoWidth: nil, year: year, isrc: isrc)
  }
}
