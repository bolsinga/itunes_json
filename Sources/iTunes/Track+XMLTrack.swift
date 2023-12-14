//
//  Track+XMLTrack.swift
//
//
//  Created by Greg Bolsinga on 12/12/23.
//

import Foundation

extension XMLTrack {
  var xalbumRating: Int? {
    if let albumRating { return Int(albumRating) }
    return nil
  }

  var xbitRate: Int? {
    if let bitRate { return Int(bitRate) }
    return nil
  }

  var xbPM: Int? {
    if let bPM { return Int(bPM) }
    return nil
  }

  var xcompilation: Bool? {
    if let compilation { return Bool(compilation) }
    return nil
  }

  var xdisabled: Bool? {
    if let disabled { return Bool(disabled) }
    return nil
  }

  var xdiscCount: Int? {
    if let discCount { return Int(discCount) }
    return nil
  }

  var xdiscNumber: Int? {
    if let discNumber { return Int(discNumber) }
    return nil
  }

  var xepisodeOrder: Int? {
    if let episodeOrder { return Int(episodeOrder) }
    return nil
  }

  var xexplicit: Bool? {
    if let explicit { return Bool(explicit) }
    return nil
  }

  var xhasVideo: Bool? {
    if let hasVideo { return Bool(hasVideo) }
    return nil
  }

  var xhD: Bool? {
    if let hd { return Bool(hd) }
    return nil
  }

  var xmovie: Bool? {
    if let movie { return Bool(movie) }
    return nil
  }

  var xmusicVideo: Bool? {
    if let musicVideo { return Bool(musicVideo) }
    return nil
  }

  var xpartOfGaplessAlbum: Bool? {
    if let partOfGaplessAlbum { return Bool(partOfGaplessAlbum) }
    return nil
  }

  var xpersistentID: UInt {
    guard let uintID = UInt(persistentID) else { preconditionFailure() }
    return uintID
  }

  var xplayCount: Int? {
    if let playCount { return Int(playCount) }
    return nil
  }

  var xpodcast: Bool? {
    if let podcast { return Bool(podcast) }
    return nil
  }

  var xprotected: Bool? {
    if let protected { return Bool(protected) }
    return nil
  }

  var xpurchased: Bool? {
    if let purchased { return Bool(purchased) }
    return nil
  }

  var xrating: Int? {
    if let rating { return Int(rating) }
    return nil
  }

  var xsampleRate: Int? {
    if let sampleRate { return Int(sampleRate) }
    return nil
  }

  var xseason: Int? {
    if let season { return Int(season) }
    return nil
  }

  var xsize: UInt64? {
    if let size { return UInt64(size) }
    return nil
  }

  var xskipCount: Int? {
    if let skipCount { return Int(skipCount) }
    return nil
  }

  var xtotalTime: Int? {
    if let totalTime { return Int(totalTime) }
    return nil
  }

  var xtrackCount: Int? {
    if let trackCount { return Int(trackCount) }
    return nil
  }

  var xtrackNumber: Int? {
    if let trackNumber { return Int(trackNumber) }
    return nil
  }

  var xtVShow: Bool? {
    if let tVShow { return Bool(tVShow) }
    return nil
  }

  var xunplayed: Bool? {
    if let unplayed { return Bool(unplayed) }
    return nil
  }

  var xyear: Int? {
    if let year { return Int(year) }
    return nil
  }
}

extension Track {
  static public func createFromXMLTrack(_ x: XMLTrack) -> Track {
    Track(
      album: x.album,
      albumArtist: x.albumArtist,
      albumRating: x.xalbumRating,
      albumRatingComputed: x.albumRatingComputed,
      artist: x.artist,
      bitRate: x.xbitRate,
      bPM: x.xbPM,
      comments: x.comments,
      compilation: x.xcompilation,
      composer: x.composer,
      contentRating: x.contentRating,
      dateAdded: x.dateAdded,
      dateModified: x.dateModified,
      disabled: x.xdisabled,
      discCount: x.xdiscCount,
      discNumber: x.xdiscNumber,
      episode: x.episode,
      episodeOrder: x.xepisodeOrder,
      explicit: x.xexplicit,
      genre: x.genre,
      grouping: x.grouping,
      hasVideo: x.xhasVideo,
      hD: x.xhD,
      kind: x.kind,
      location: x.location,
      movie: x.xmovie,
      musicVideo: x.xmusicVideo,
      name: x.name,
      partOfGaplessAlbum: x.xpartOfGaplessAlbum,
      persistentID: x.xpersistentID,
      playCount: x.xplayCount,
      playDateUTC: x.playDateUTC,
      podcast: x.xpodcast,
      protected: x.xprotected,
      purchased: x.xpurchased,
      rating: x.xrating,
      ratingComputed: x.ratingComputed,
      releaseDate: x.releaseDate,
      sampleRate: x.xsampleRate,
      season: x.xseason,
      series: x.series,
      size: x.xsize,
      skipCount: x.xskipCount,
      skipDate: x.skipDate,
      sortAlbum: x.sortAlbum,
      sortAlbumArtist: x.sortAlbumArtist,
      sortArtist: x.sortArtist,
      sortComposer: x.sortComposer,
      sortName: x.sortName,
      sortSeries: x.sortSeries,
      totalTime: x.xtotalTime,
      trackCount: x.xtrackCount,
      trackNumber: x.xtrackNumber,
      trackType: x.trackType,
      tVShow: x.xtVShow,
      unplayed: x.xunplayed,
      videoHeight: x.videoHeight,
      videoWidth: x.videoWidth,
      year: x.xyear)
  }
}
