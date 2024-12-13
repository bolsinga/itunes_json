//
//  Track+Song.swift
//
//
//  Created by Greg Bolsinga on 10/31/23.
//

import Foundation
import MusicKit

extension Track {
  init(section album: MusicLibrarySection<Album, Song>, song: Song) {
    self.album = song.albumTitle
    self.artist = song.artistName
    self.albumArtist = album.artistName
    //      self.albumRating = album.rating
    //      self.albumRatingComputed = song.isRatingComputed
    //      self.bitRate = song.bitrate
    //      self.bPM = song.beatsPerMinute
    //      self.comments = comments
    if let isCompilation = album.isCompilation, isCompilation {
      self.compilation = true
    }
    self.composer = song.composerName
    //      self.contentRating = contentRating // tv
    self.dateAdded = song.libraryAddedDate
    //      self.dateModified = date
    //      self.disabled = song.isUserDisabled
    //      self.discCount = album.discCount
    self.discNumber = song.discNumber
    if let contentRating = song.contentRating, contentRating == .explicit {
      self.explicit = true
    }
    self.genre = song.genreNames.first
    //      self.grouping = grouping
    //      self.hasVideo = true
    //      self.kind = kind
    //      self.location = location.absoluteString
    //      self.movie = true
    //      self.musicVideo = true
    //      self.podcast = true
    //      self.tVShow = true
    self.name = song.title
    //      self.partOfGaplessAlbum = album.isGapless
    //
    if let value = Int(song.id.rawValue) {
      self.persistentID = UInt(bitPattern: value)
    } else {
      self.persistentID = 0
    }
    self.playCount = song.playCount
    self.playDateUTC = song.lastPlayedDate
    //      self.protected = song.isDRMProtected
    //      self.purchased = song.isPurchased
    //      self.rating = song.rating
    //      self.ratingComputed = song.isRatingComputed
    self.releaseDate = song.releaseDate
    //    self.sampleRate = song.sampleRate
    //    self.size = song.fileSize
    //      self.skipCount = song.skipCount
    //      self.skipDate = date
    //      self.sortAlbum = name
    //      self.sortAlbumArtist = name
    //      self.sortArtist = name
    //      self.sortComposer = sortComposer
    //      self.sortName = sortName
    if let duration = song.duration {
      self.totalTime = Int(duration)
    }
    self.trackCount = album.trackCount
    self.trackNumber = song.trackNumber
    //      self.trackType = "File"
    //      self.trackType = "URL"
    //      self.trackType = "Remote"
    //      self.unplayed = playStatus
    //    self.year = song.year

    //    if let videoInfo = song.videoInfo {
    //      if let episode = videoInfo.episode {
    //        self.episode = episode
    //      }
    //      if videoInfo.episodeOrder != 0 {
    //        self.episodeOrder = videoInfo.episodeOrder
    //      }
    //      if videoInfo.isHD {
    //        self.hD = videoInfo.isHD
    //      }
    //      if videoInfo.season != 0 {
    //        self.season = videoInfo.season
    //      }
    //      if let series = videoInfo.series {
    //        self.series = series
    //      }
    //      if let sortSeries = videoInfo.sortSeries {
    //        self.sortSeries = sortSeries
    //      }
    //      if videoInfo.videoHeight != 0 {
    //        self.videoHeight = videoInfo.videoHeight
    //      }
    //      if videoInfo.videoWidth != 0 {
    //        self.videoWidth = videoInfo.videoWidth
    //      }
    //    }
    self.isrc = song.isrc
  }
}

extension Track {
  static func requestAccess() async {
    let musicAuthorizationStatus = await MusicAuthorization.request()
    print("\(musicAuthorizationStatus)")
  }

  static func gatherWithMusicKit() async throws -> [Track] {
    await requestAccess()

    let request = MusicLibrarySectionedRequest<Album, Song>()
    let response = try await request.response()
    return response.sections.flatMap { section in
      section.items.map { Track(section: section, song: $0) }
    }
  }
}
