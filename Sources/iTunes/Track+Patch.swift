//
//  Track+Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let patch = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "patch")
}

extension AlbumArtistName.AlbumType {
  fileprivate var compilation: Bool? {
    isCompilation ? true : nil
  }
}

extension Track {
  fileprivate func apply(patch: ArtistPatchLookup.Value, tag: String) -> Track {
    Logger.patch.info("Patching: \(patch) - \(tag)")

    return Track(
      album: album,
      albumArtist: albumArtist,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: patch.name,
      bitRate: bitRate,
      bPM: bPM,
      comments: comments,
      compilation: compilation,
      composer: composer,
      contentRating: contentRating,
      dateAdded: dateAdded,
      dateModified: dateModified,
      disabled: disabled,
      discCount: discCount,
      discNumber: discNumber,
      episode: episode,
      episodeOrder: episodeOrder,
      explicit: explicit,
      genre: genre,
      grouping: grouping,
      hasVideo: hasVideo,
      hD: hD,
      kind: kind,
      location: location,
      movie: movie,
      musicVideo: musicVideo,
      name: name,
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
      series: series,
      size: size,
      skipCount: skipCount,
      skipDate: skipDate,
      sortAlbum: sortAlbum,
      sortAlbumArtist: sortAlbumArtist,
      sortArtist: !patch.sorted.isEmpty ? patch.sorted : nil,
      sortComposer: sortComposer,
      sortName: sortName,
      sortSeries: sortSeries,
      totalTime: totalTime,
      trackCount: trackCount,
      trackNumber: trackNumber,
      trackType: trackType,
      tVShow: tVShow,
      unplayed: unplayed,
      videoHeight: videoHeight,
      videoWidth: videoWidth,
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(patch: AlbumPatchLookup.Value, tag: String) -> Track {
    Logger.patch.info("Patching: \(patch) - \(tag)")

    return Track(
      album: patch.name.name,
      albumArtist: albumArtist,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: artist,
      bitRate: bitRate,
      bPM: bPM,
      comments: comments,
      compilation: patch.type.compilation,
      composer: composer,
      contentRating: contentRating,
      dateAdded: dateAdded,
      dateModified: dateModified,
      disabled: disabled,
      discCount: discCount,
      discNumber: discNumber,
      episode: episode,
      episodeOrder: episodeOrder,
      explicit: explicit,
      genre: genre,
      grouping: grouping,
      hasVideo: hasVideo,
      hD: hD,
      kind: kind,
      location: location,
      movie: movie,
      musicVideo: musicVideo,
      name: name,
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
      series: series,
      size: size,
      skipCount: skipCount,
      skipDate: skipDate,
      sortAlbum: !patch.name.sorted.isEmpty ? patch.name.sorted : nil,
      sortAlbumArtist: sortAlbumArtist,
      sortArtist: sortArtist,
      sortComposer: sortComposer,
      sortName: sortName,
      sortSeries: sortSeries,
      totalTime: totalTime,
      trackCount: trackCount,
      trackNumber: trackNumber,
      trackType: trackType,
      tVShow: tVShow,
      unplayed: unplayed,
      videoHeight: videoHeight,
      videoWidth: videoWidth,
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(albumTitle newAlbumTitle: SortableName, tag: String) -> Track {
    Logger.patch.info("Patching Title: \(newAlbumTitle) - \(tag)")

    return Track(
      album: newAlbumTitle.name,
      albumArtist: albumArtist,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: artist,
      bitRate: bitRate,
      bPM: bPM,
      comments: comments,
      compilation: compilation,
      composer: composer,
      contentRating: contentRating,
      dateAdded: dateAdded,
      dateModified: dateModified,
      disabled: disabled,
      discCount: discCount,
      discNumber: discNumber,
      episode: episode,
      episodeOrder: episodeOrder,
      explicit: explicit,
      genre: genre,
      grouping: grouping,
      hasVideo: hasVideo,
      hD: hD,
      kind: kind,
      location: location,
      movie: movie,
      musicVideo: musicVideo,
      name: name,
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
      series: series,
      size: size,
      skipCount: skipCount,
      skipDate: skipDate,
      sortAlbum: !newAlbumTitle.sorted.isEmpty ? newAlbumTitle.sorted : nil,
      sortAlbumArtist: sortAlbumArtist,
      sortArtist: sortArtist,
      sortComposer: sortComposer,
      sortName: sortName,
      sortSeries: sortSeries,
      totalTime: totalTime,
      trackCount: trackCount,
      trackNumber: trackNumber,
      trackType: trackType,
      tVShow: tVShow,
      unplayed: unplayed,
      videoHeight: videoHeight,
      videoWidth: videoWidth,
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(trackCount newTrackCount: Int, tag: String) -> Track {
    Logger.patch.info("Patching TrackCount: \(newTrackCount) - \(tag)")

    return Track(
      album: album,
      albumArtist: albumArtist,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: artist,
      bitRate: bitRate,
      bPM: bPM,
      comments: comments,
      compilation: compilation,
      composer: composer,
      contentRating: contentRating,
      dateAdded: dateAdded,
      dateModified: dateModified,
      disabled: disabled,
      discCount: discCount,
      discNumber: discNumber,
      episode: episode,
      episodeOrder: episodeOrder,
      explicit: explicit,
      genre: genre,
      grouping: grouping,
      hasVideo: hasVideo,
      hD: hD,
      kind: kind,
      location: location,
      movie: movie,
      musicVideo: musicVideo,
      name: name,
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
      series: series,
      size: size,
      skipCount: skipCount,
      skipDate: skipDate,
      sortAlbum: sortAlbum,
      sortAlbumArtist: sortAlbumArtist,
      sortArtist: sortArtist,
      sortComposer: sortComposer,
      sortName: sortName,
      sortSeries: sortSeries,
      totalTime: totalTime,
      trackCount: newTrackCount,
      trackNumber: trackNumber,
      trackType: trackType,
      tVShow: tVShow,
      unplayed: unplayed,
      videoHeight: videoHeight,
      videoWidth: videoWidth,
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(trackCorrection: TrackCorrection, tag: String) -> Track {
    Logger.patch.info("Patching TrackCorrection: \(trackCorrection) - \(tag)")
    switch trackCorrection.correction {
    case .albumTitle(let newTitle):
      guard albumName != newTitle else { return self }
      return apply(albumTitle: newTitle, tag: tag)
    case .trackCount(let newTrackCount):
      guard let trackCount, trackCount != newTrackCount else { return self }
      return apply(trackCount: newTrackCount, tag: tag)
    case .artistName(let newArtistName):
      guard newArtistName != artistName else { return self }
      return apply(patch: newArtistName, tag: tag)
    }
  }

  fileprivate func apply(trackNumber newTrackNumber: Int, tag: String) -> Track {
    Logger.patch.info("Patching TrackNumber: \(newTrackNumber) - \(tag)")

    return Track(
      album: album,
      albumArtist: albumArtist,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: artist,
      bitRate: bitRate,
      bPM: bPM,
      comments: comments,
      compilation: compilation,
      composer: composer,
      contentRating: contentRating,
      dateAdded: dateAdded,
      dateModified: dateModified,
      disabled: disabled,
      discCount: discCount,
      discNumber: discNumber,
      episode: episode,
      episodeOrder: episodeOrder,
      explicit: explicit,
      genre: genre,
      grouping: grouping,
      hasVideo: hasVideo,
      hD: hD,
      kind: kind,
      location: location,
      movie: movie,
      musicVideo: musicVideo,
      name: name,
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
      series: series,
      size: size,
      skipCount: skipCount,
      skipDate: skipDate,
      sortAlbum: sortAlbum,
      sortAlbumArtist: sortAlbumArtist,
      sortArtist: sortArtist,
      sortComposer: sortComposer,
      sortName: sortName,
      sortSeries: sortSeries,
      totalTime: totalTime,
      trackCount: trackCount,
      trackNumber: newTrackNumber,
      trackType: trackType,
      tVShow: tVShow,
      unplayed: unplayed,
      videoHeight: videoHeight,
      videoWidth: videoWidth,
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(year newYear: Int, tag: String) -> Track {
    Logger.patch.info("Patching Year: \(newYear) - \(tag)")

    return Track(
      album: album,
      albumArtist: albumArtist,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: artist,
      bitRate: bitRate,
      bPM: bPM,
      comments: comments,
      compilation: compilation,
      composer: composer,
      contentRating: contentRating,
      dateAdded: dateAdded,
      dateModified: dateModified,
      disabled: disabled,
      discCount: discCount,
      discNumber: discNumber,
      episode: episode,
      episodeOrder: episodeOrder,
      explicit: explicit,
      genre: genre,
      grouping: grouping,
      hasVideo: hasVideo,
      hD: hD,
      kind: kind,
      location: location,
      movie: movie,
      musicVideo: musicVideo,
      name: name,
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
      series: series,
      size: size,
      skipCount: skipCount,
      skipDate: skipDate,
      sortAlbum: sortAlbum,
      sortAlbumArtist: sortAlbumArtist,
      sortArtist: sortArtist,
      sortComposer: sortComposer,
      sortName: sortName,
      sortSeries: sortSeries,
      totalTime: totalTime,
      trackCount: trackCount,
      trackNumber: trackNumber,
      trackType: trackType,
      tVShow: tVShow,
      unplayed: unplayed,
      videoHeight: videoHeight,
      videoWidth: videoWidth,
      year: newYear,
      isrc: isrc)
  }
}

extension Array where Element == Track {
  fileprivate func patchArtists(_ lookup: ArtistPatchLookup, tag: String) throws -> [Track] {
    self.map { track in
      guard let name = track.artistName, let patch = lookup[name] else { return track }
      return track.apply(patch: patch, tag: tag)
    }
  }

  fileprivate func patchAlbums(_ lookup: AlbumPatchLookup, tag: String) throws -> [Track] {
    self.map { track in
      guard let name = track.albumArtistName, let patch = lookup[name] else { return track }
      return track.apply(patch: patch, tag: tag)
    }
  }

  fileprivate func patchMissingAlbumTitles(_ lookup: AlbumMissingTitlePatchLookup, tag: String)
    throws
    -> [Track]
  {
    self.map { track in
      guard track.albumName == nil, let songArtist = track.songArtist,
        let title = lookup[songArtist]
      else { return track }
      return track.apply(albumTitle: title, tag: tag)
    }
  }

  fileprivate func patchAlbumTrackCounts(_ lookup: AlbumTrackCountLookup, tag: String) throws
    -> [Track]
  {
    self.map { track in
      guard track.isSQLEncodable, let name = track.albumArtistName,
        let correctedTrackCount = lookup[name]
      else {
        return track
      }
      return track.apply(trackCount: correctedTrackCount, tag: tag)
    }
  }

  fileprivate func patchTrackCorrections(_ corrections: [TrackCorrection], tag: String) throws
    -> [Track]
  {
    self.map { track in
      guard let songArtistAlbum = track.songArtistAlbum else { return track }
      let applicableCorrections = corrections.matches(songArtistAlbum)
      guard !applicableCorrections.isEmpty else { return track }
      guard applicableCorrections.count == 1 else {
        Logger.patch.info("Too Many Applicable Corrections: \(applicableCorrections) - \(tag)")
        return track
      }
      return track.apply(trackCorrection: applicableCorrections[0], tag: tag)
    }
  }

  fileprivate func patchSongTrackNumbers(_ lookup: SongTrackNumberLookup, tag: String) throws
    -> [Track]
  {
    self.map { track in
      guard track.isSQLEncodable, let name = track.songArtistAlbum,
        let correctedTrackNumber = lookup[name]
      else {
        return track
      }
      return track.apply(trackNumber: correctedTrackNumber, tag: tag)
    }
  }

  fileprivate func patchSongYears(_ lookup: SongYearLookup, tag: String) throws -> [Track] {
    self.map { track in
      guard track.isSQLEncodable, let name = track.songArtistAlbum, let correctedYear = lookup[name]
      else { return track }
      return track.apply(year: correctedYear, tag: tag)
    }
  }

  fileprivate func patchTracks(_ patch: Patch, tag: String) throws -> [Track] {
    switch patch {
    case .artists(let lookup):
      try patchArtists(lookup, tag: tag)
    case .albums(let lookup):
      try patchAlbums(lookup, tag: tag)
    case .missingTitleAlbums(let lookup):
      try patchMissingAlbumTitles(lookup, tag: tag)
    case .trackCounts(let lookup):
      try patchAlbumTrackCounts(lookup, tag: tag)
    case .trackCorrections(let lookup):
      try patchTrackCorrections(lookup, tag: tag)
    case .trackNumbers(let lookup):
      try patchSongTrackNumbers(lookup, tag: tag)
    case .years(let lookup):
      try patchSongYears(lookup, tag: tag)
    }
  }

  func patch(_ patch: Patch, tag: String) throws -> Data {
    try patchTracks(patch, tag: tag).jsonData()
  }
}
