//
//  Track+ReduceFields.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 10/21/24.
//

import Foundation

extension Track {
  var duplicateAndEmptyFieldsRemoved: Track {
    let rSortAlbum = self.sortAlbum?.uniqueNonEmptyString(self.album)
    let rSortArtist = self.sortArtist?.uniqueNonEmptyString(self.artist)
    let rSortAlbumArtist = self.sortAlbumArtist?.uniqueNonEmptyString(rSortArtist)
    let rSortComposer = self.sortComposer?.uniqueNonEmptyString(self.composer)
    let rSortName = self.sortName?.uniqueNonEmptyString(self.name)

    return Track(
      album: album?.nonEmptyString,
      albumArtist: albumArtist?.nonEmptyString,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: artist?.nonEmptyString,
      bitRate: bitRate,
      bPM: bPM,
      comments: comments?.nonEmptyString,
      compilation: compilation,
      composer: composer?.nonEmptyString,
      contentRating: contentRating?.nonEmptyString,
      dateAdded: dateAdded,
      dateModified: dateModified,
      disabled: disabled,
      discCount: discCount,
      discNumber: discNumber,
      episode: episode?.nonEmptyString,
      episodeOrder: episodeOrder,
      explicit: explicit,
      genre: genre?.nonEmptyString,
      grouping: grouping?.nonEmptyString,
      hasVideo: hasVideo,
      hD: hD,
      kind: kind?.nonEmptyString,
      location: location?.nonEmptyString,
      movie: movie,
      musicVideo: musicVideo,
      name: name,  // Non-Optional
      partOfGaplessAlbum: partOfGaplessAlbum,
      persistentID: persistentID,
      playCount: playCount,
      playDateUTC: playDateUTC,
      podcast: podcast,
      protected: protected,
      purchased: purchased,
      rating: rating,
      ratingComputed: ratingComputed,
      releaseDate: releaseDate,
      sampleRate: sampleRate,
      season: season,
      series: series?.nonEmptyString,
      size: size,
      skipCount: skipCount,
      skipDate: skipDate,
      sortAlbum: rSortAlbum,
      sortAlbumArtist: rSortAlbumArtist,
      sortArtist: rSortArtist,
      sortComposer: rSortComposer,
      sortName: rSortName,
      sortSeries: sortSeries?.nonEmptyString,
      totalTime: totalTime,
      trackCount: trackCount,
      trackNumber: trackNumber,
      trackType: trackType?.nonEmptyString,
      tVShow: tVShow,
      unplayed: unplayed,
      videoHeight: videoHeight,
      videoWidth: videoWidth,
      year: year)
  }
}
