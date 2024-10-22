//
//  Track+ReduceSortFields.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 10/21/24.
//

import Foundation

extension Track {
  var duplicateSortFieldsRemoved: Track {
    let rSortAlbum = self.sortAlbum?.uniqueNonEmptyString(self.album)
    let rSortArtist = self.sortArtist?.uniqueNonEmptyString(self.artist)
    let rSortAlbumArtist = self.sortAlbumArtist?.uniqueNonEmptyString(rSortArtist)
    let rSortComposer = self.sortComposer?.uniqueNonEmptyString(self.composer)
    let rSortName = self.sortName?.uniqueNonEmptyString(self.name)

    return Track(
      album: album, albumArtist: albumArtist, albumRating: albumRating,
      albumRatingComputed: albumRatingComputed, artist: artist, bitRate: bitRate, bPM: bPM,
      comments: comments, compilation: compilation, composer: composer,
      contentRating: contentRating, dateAdded: dateAdded, dateModified: dateModified,
      disabled: disabled, discCount: discCount, discNumber: discNumber, episode: episode,
      episodeOrder: episodeOrder, explicit: explicit, genre: genre, grouping: grouping,
      hasVideo: hasVideo, hD: hD, kind: kind, location: location, movie: movie,
      musicVideo: musicVideo, name: name, partOfGaplessAlbum: partOfGaplessAlbum,
      persistentID: persistentID, playCount: playCount, playDateUTC: playDateUTC,
      podcast: podcast, protected: protected, purchased: purchased, rating: rating,
      ratingComputed: ratingComputed, releaseDate: releaseDate, sampleRate: sampleRate,
      season: season, series: series, size: size, skipCount: skipCount, skipDate: skipDate,
      sortAlbum: rSortAlbum, sortAlbumArtist: rSortAlbumArtist, sortArtist: rSortArtist,
      sortComposer: rSortComposer, sortName: rSortName, sortSeries: sortSeries,
      totalTime: totalTime, trackCount: trackCount, trackNumber: trackNumber,
      trackType: trackType, tVShow: tVShow, unplayed: unplayed, videoHeight: videoHeight,
      videoWidth: videoWidth, year: year)
  }
}
