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

extension Track {
  fileprivate func apply(patch: ArtistPatchLookup.Value) -> Track {
    Logger.patch.info("Patching: \(patch)")

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
      sortArtist: patch.sorted,
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

  fileprivate func apply(patch: AlbumPatchLookup.Value) -> Track {
    Logger.patch.info("Patching: \(patch)")

    return Track(
      album: patch.name.name,
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
      sortAlbum: patch.name.sorted,
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
}

extension Array where Element == Track {
  fileprivate func patchArtists(_ lookup: ArtistPatchLookup) throws -> [Track] {
    self.map { track in
      guard let name = track.artistName, let patch = lookup[name] else { return track }
      return track.apply(patch: patch)
    }
  }

  fileprivate func patchAlbums(_ lookup: AlbumPatchLookup) throws -> [Track] {
    self.map { track in
      guard let name = track.albumArtistName, let patch = lookup[name] else { return track }
      return track.apply(patch: patch)
    }
  }

  fileprivate func patchTracks(_ patch: Patch) throws -> [Track] {
    switch patch {
    case .artists(let lookup):
      try patchArtists(lookup)
    case .albums(let lookup):
      try patchAlbums(lookup)
    }
  }

  public func patch(_ patch: Patch) throws -> Data {
    try patchTracks(patch).jsonData()
  }
}
