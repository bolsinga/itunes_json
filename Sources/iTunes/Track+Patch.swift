//
//  Track+Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let patch = Logger(category: "patch")
}

extension Track {
  fileprivate func apply(patch: SortableName, tag: String) -> Track {
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

  fileprivate func apply(discCount newDiscCount: Int, tag: String) -> Track {
    Logger.patch.info("Patching DiscCount: \(newDiscCount) - \(tag)")

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
      discCount: newDiscCount,
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
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(discNumber newDiscNumber: Int, tag: String) -> Track {
    Logger.patch.info("Patching DiscNumber: \(newDiscNumber) - \(tag)")

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
      discNumber: newDiscNumber,
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
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(duration newDuration: Int, tag: String) -> Track {
    Logger.patch.info("Patching Duration: \(newDuration) - \(tag)")

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
      totalTime: newDuration,
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

  fileprivate func apply(persistentID newPersistentID: UInt, tag: String) -> Track {
    Logger.patch.info("Patching PersistentID: \(newPersistentID) - \(tag)")

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
      persistentID: newPersistentID,
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
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(dateAdded newDateAdded: String, tag: String) -> Track {
    Logger.patch.info("Patching DateAdded: \(newDateAdded) - \(tag)")

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
      dateAdded: newDateAdded,
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
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(composer newComposer: String, tag: String) -> Track {
    Logger.patch.info("Patching Composer: \(newComposer) - \(tag)")

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
      composer: !newComposer.isEmpty ? newComposer : nil,
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
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(comments newComments: String, tag: String) -> Track {
    Logger.patch.info("Patching Comments: \(newComments) - \(tag)")

    return Track(
      album: album,
      albumArtist: albumArtist,
      albumRating: albumRating,
      albumRatingComputed: albumRatingComputed,
      artist: artist,
      bitRate: bitRate,
      bPM: bPM,
      comments: !newComments.isEmpty ? newComments : nil,
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
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(dateReleased newDateReleased: String, tag: String) -> Track {
    Logger.patch.info("Patching DateReleased: \(newDateReleased) - \(tag)")

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
      releaseDate: newDateReleased,
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
      year: year,
      isrc: isrc)
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

  fileprivate func apply(playDate newPlayDate: String, count newPlayCount: Int, tag: String)
    -> Track
  {
    Logger.patch.info("Patching Play: \(newPlayDate) (\(newPlayCount)) - \(tag)")

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
      playCount: newPlayCount,
      playDateUTC: newPlayDate,
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
      year: year,
      isrc: isrc)
  }

  fileprivate func apply(song newSong: SortableName, tag: String) -> Track {
    Logger.patch.info("Patching Song: \(newSong) - \(tag)")

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
      name: newSong.name,
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
      sortName: !newSong.sorted.isEmpty ? newSong.sorted : nil,
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

  fileprivate func apply(correction: IdentityRepair.Correction, tag: String) -> Track {
    Logger.patch.info("Patching Correction: \(correction) - \(tag)")
    switch correction {
    case .duration(let newValue):
      guard let newValue else { return self }
      if let totalTime, totalTime == newValue { return self }
      return self.apply(duration: newValue, tag: tag)
    case .persistentID(let newValue):
      if persistentID == newValue { return self }
      return self.apply(persistentID: newValue, tag: tag)
    case .dateAdded(let newValue):
      guard let newValue else { return self }
      if let dateAdded, dateAdded == newValue { return self }
      return self.apply(dateAdded: newValue, tag: tag)
    case .composer(let newValue):
      if let composer, composer == newValue { return self }
      return self.apply(composer: newValue, tag: tag)
    case .comments(let newValue):
      if let comments, comments == newValue { return self }
      return self.apply(comments: newValue, tag: tag)
    case .dateReleased(let newValue):
      guard let newValue else { return self }
      if let releaseDate, releaseDate == newValue { return self }
      return self.apply(dateReleased: newValue, tag: tag)
    case .albumTitle(let newValue):
      guard let newValue else { return self }
      if let albumName, albumName == newValue { return self }
      return self.apply(albumTitle: newValue, tag: tag)
    case .year(let newValue):
      if year == newValue { return self }
      return self.apply(year: newValue, tag: tag)
    case .trackNumber(let newValue):
      if trackNumber == newValue { return self }
      return self.apply(trackNumber: newValue, tag: tag)
    case .replaceSongTitle(let newValue):
      // Note: This will always set the title w/o checking if it is different.
      return self.apply(song: newValue, tag: tag)
    case .discCount(let newValue):
      if discCount == newValue { return self }
      return self.apply(discCount: newValue, tag: tag)
    case .discNumber(let newValue):
      if discNumber == newValue { return self }
      return self.apply(discNumber: newValue, tag: tag)
    case .artist(let newValue):
      guard let newValue else { return self }
      if artistName == newValue { return self }
      return self.apply(patch: newValue, tag: tag)
    case .play(let old, let new):
      guard old == self.play else { return self }
      guard let date = new.date, let count = new.count else { return self }
      return self.apply(playDate: date, count: count, tag: tag)
    }
  }

  fileprivate func apply(identityRepair: IdentityRepair, tag: String) -> Track {
    Logger.patch.info("Patching IdentityRepair: \(identityRepair) - \(tag)")
    return apply(correction: identityRepair.correction, tag: tag)
  }
}

extension Array where Element == Track {
  fileprivate func patchIdentityRepairs(_ repairs: [IdentityRepair], tag: String)
    throws
    -> [Track]
  {
    let lookup = repairs.reduce(into: [UInt: [IdentityRepair]]()) {
      var result = $0[$1.persistentID] ?? []
      result.append($1)
      $0[$1.persistentID] = result
    }
    return self.map {
      guard let repairs = lookup[$0.persistentID] else { return $0 }

      var result = $0
      repairs.forEach { repair in
        result = result.apply(identityRepair: repair, tag: tag)
      }
      return result
    }
  }

  fileprivate func patchTracks(_ patch: Patch, tag: String) throws -> [Track] {
    switch patch {
    case .identityRepairs(let items):
      try patchIdentityRepairs(items, tag: tag)
    }
  }

  func patch(_ patch: Patch, tag: String) throws -> Data {
    try patchTracks(patch, tag: tag).jsonData()
  }

  func backupPatch(_ patchURL: URL) async throws -> [Track] {
    try patchTracks(try await Patch.load(patchURL), tag: "")
  }
}
