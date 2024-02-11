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

  internal func criteriaApplies(_ criteria: Set<Criterion>) -> Bool {
    guard !criteria.isEmpty else { return false }

    for criterion in criteria {
      guard criterionApplies(criterion) else {
        return false
      }
    }
    return true
  }

  internal func remedyApplies(_ remedy: Remedy) -> Bool {
    switch remedy {
    case .ignore:
      return true
    case .repairEmptySortArtist(_):
      return sortArtist == nil
    case .repairEmptyKind(_):
      return kind == nil
    case .repairEmptyYear(_):
      return year == nil
    case .repairEmptyTrackCount(_):
      return trackCount == nil
    case .repairEmptyTrackNumber(_):
      return trackNumber == nil
    case .repairEmptyAlbum(_):
      return album == nil
    case .replaceArtist(_):
      return artist != nil
    }
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
    case .repairEmptySortArtist(let string):
      return self.update(fixedSortArtist: string)
    case .repairEmptyKind(let string):
      return self.update(fixedKind: string)
    case .repairEmptyYear(let int):
      return self.update(fixedYear: int)
    case .repairEmptyTrackCount(let int):
      return self.update(fixedTrackCount: int)
    case .repairEmptyTrackNumber(let int):
      return self.update(fixedTrackNumber: int)
    case .repairEmptyAlbum(let string):
      return self.update(fixedAlbum: string)
    case .replaceArtist(let string):
      return self.update(fixedArtist: string)
    }
  }

  func repair(_ issue: Issue) -> Track? {
    guard criteriaApplies(issue.criteria) else {
      return self
    }

    var fixedTrack: Track? = self
    for remedy in issue.remedies {
      guard let track = fixedTrack else { break }
      if track.remedyApplies(remedy) {
        fixedTrack = track.applyRemedy(remedy)
      }
    }
    return fixedTrack
  }
}
