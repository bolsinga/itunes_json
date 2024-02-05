//
//  Track+Repair.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation

extension Track {
  internal func criterionApplies(_ criterion: Criterion) -> Bool {
    switch criterion {
    case .album(let string):
      guard let album else { return false }
      return album == string
    case .artist(let string):
      guard let artist else { return false }
      return artist == string
    case .song(let string):
      return name == string
    }
  }

  internal func criteriaApplies(_ criteria: [Criterion]) -> Bool {
    for criterion in criteria {
      guard criterionApplies(criterion) else { return false }
    }
    return true
  }

  private func update(
    fixedAlbum: String? = nil, fixedArtist: String? = nil, fixedKind: String? = nil,
    fixedPlayCount: Int? = nil, fixedPlayDate: Date? = nil, fixedSortArtist: String? = nil,
    fixedTrackCount: Int? = nil, fixedTrackNumber: Int? = nil, fixedYear: Int? = nil
  ) -> Track {
    Track(
      album: fixedAlbum ?? album, albumArtist: albumArtist, albumRating: albumRating,
      albumRatingComputed: albumRatingComputed, artist: fixedArtist ?? artist, bitRate: bitRate,
      bPM: bPM,
      comments: comments, compilation: compilation, composer: composer,
      contentRating: contentRating, dateAdded: dateAdded, dateModified: dateModified,
      disabled: disabled, discCount: discCount, discNumber: discNumber, episode: episode,
      episodeOrder: episodeOrder, explicit: explicit, genre: genre, grouping: grouping,
      hasVideo: hasVideo, hD: hD, kind: fixedKind ?? kind, location: location, movie: movie,
      musicVideo: musicVideo, name: name, partOfGaplessAlbum: partOfGaplessAlbum,
      persistentID: persistentID, playCount: fixedPlayCount ?? playCount,
      playDateUTC: fixedPlayDate ?? playDateUTC,
      podcast: podcast, protected: protected, purchased: purchased, rating: rating,
      ratingComputed: ratingComputed, releaseDate: releaseDate, sampleRate: sampleRate,
      season: season, series: series, size: size, skipCount: skipCount, skipDate: skipDate,
      sortAlbum: sortAlbum, sortAlbumArtist: sortAlbumArtist,
      sortArtist: fixedSortArtist ?? sortArtist,
      sortComposer: sortComposer, sortName: sortName, sortSeries: sortSeries,
      totalTime: totalTime, trackCount: fixedTrackCount ?? trackCount,
      trackNumber: fixedTrackNumber ?? trackNumber,
      trackType: trackType, tVShow: tVShow, unplayed: unplayed, videoHeight: videoHeight,
      videoWidth: videoWidth, year: fixedYear ?? year)
  }

  internal func applyRemedy(_ remedy: Remedy) -> Track? {
    switch remedy {
    case .ignore:
      return nil
    case .correctSortArtist(let string):
      guard sortArtist == nil else { return self }
      return self.update(fixedSortArtist: string)
    case .correctKind(let string):
      guard kind == nil else { return self }
      return self.update(fixedKind: string)
    case .correctYear(let int):
      guard year == nil else { return self }
      return self.update(fixedYear: int)
    case .correctTrackCount(let int):
      guard trackCount == nil else { return self }
      return self.update(fixedTrackCount: int)
    }
  }

  func repair(_ issue: Issue) -> Track? {
    guard issue.isValid else { return self }
    guard criteriaApplies(issue.critera) else { return self }

    var fixedTrack: Track? = self
    for remedy in issue.remedies {
      fixedTrack = fixedTrack?.applyRemedy(remedy)
    }
    return fixedTrack
  }
}
