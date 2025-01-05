//
//  Track+MediaItem.swift
//
//
//  Created by Greg Bolsinga on 1/2/22.
//

import Foundation

#if canImport(iTunesLibrary)
  import iTunesLibrary

  extension Track {
    init(_ mediaItem: ITLibMediaItem) {
      let artist = mediaItem.artist
      let album = mediaItem.album

      self.album = album.title
      self.albumArtist = album.albumArtist
      if album.rating != 0 {
        self.albumRating = album.rating
      }
      if album.isRatingComputed {
        self.albumRatingComputed = mediaItem.isRatingComputed
      }
      self.artist = artist?.name
      //    self.ARTWORK_COUNT = mediaItem.ARTWORK_COUNT
      if mediaItem.bitrate != 0 {
        self.bitRate = mediaItem.bitrate
      }
      if mediaItem.beatsPerMinute != 0 {
        self.bPM = mediaItem.beatsPerMinute
      }
      self.comments = mediaItem.comments
      if album.isCompilation {
        self.compilation = album.isCompilation
      }
      self.composer = mediaItem.composer
      if let contentRating = mediaItem.contentRating {
        self.contentRating = contentRating
      }
      self.dateAdded = mediaItem.addedDate
      self.dateModified = mediaItem.modifiedDate
      if mediaItem.isUserDisabled {
        self.disabled = mediaItem.isUserDisabled
      }
      if album.discCount != 0 {
        self.discCount = album.discCount
      }
      if album.discNumber != 0 {
        self.discNumber = album.discNumber
      }
      if mediaItem.lyricsContentRating == .explicit {
        self.explicit = true
      }
      self.genre = mediaItem.genre
      if let grouping = mediaItem.grouping {
        self.grouping = grouping
      }
      if mediaItem.isVideo {
        self.hasVideo = true
      }
      self.kind = mediaItem.kind
      if let location = mediaItem.location {
        self.location = location.absoluteString
      }
      if mediaItem.mediaKind == .kindMovie {
        self.movie = true
      } else if mediaItem.mediaKind == .kindMusicVideo {
        self.musicVideo = true
      } else if mediaItem.mediaKind == .kindPodcast {
        self.podcast = true
      } else if mediaItem.mediaKind == .kindTVShow {
        self.tVShow = true
      }
      self.name = mediaItem.title
      if album.isGapless {
        self.partOfGaplessAlbum = album.isGapless
      }
      self.persistentID = mediaItem.persistentID.uintValue  // Hex?
      self.playCount = mediaItem.playCount
      self.playDateUTC = mediaItem.lastPlayedDate
      if mediaItem.isDRMProtected {
        self.protected = mediaItem.isDRMProtected
      }
      if mediaItem.isPurchased {
        self.purchased = mediaItem.isPurchased
      }
      if mediaItem.rating != 0 {
        self.rating = mediaItem.rating
      }
      if mediaItem.isRatingComputed {
        self.ratingComputed = mediaItem.isRatingComputed
      }
      self.releaseDate = mediaItem.releaseDate
      self.sampleRate = mediaItem.sampleRate
      self.size = mediaItem.fileSize
      if mediaItem.skipCount != 0 {
        self.skipCount = mediaItem.skipCount
      }
      self.skipDate = mediaItem.skipDate
      self.sortAlbum = album.sortTitle
      self.sortAlbumArtist = album.sortAlbumArtist
      self.sortArtist = artist?.sortName
      self.sortComposer = mediaItem.sortComposer
      self.sortName = mediaItem.sortTitle
      self.totalTime = mediaItem.totalTime
      if album.trackCount != 0 {
        self.trackCount = album.trackCount
      }
      self.trackNumber = mediaItem.trackNumber
      switch mediaItem.locationType {
      case .file:
        self.trackType = "File"
      case .URL:
        self.trackType = "URL"
      case .remote:
        self.trackType = "Remote"
      case .unknown:
        break
      @unknown default:
        break
      }
      if mediaItem.playStatus == .unplayed {
        self.unplayed = true
      }
      self.year = mediaItem.year

      if let videoInfo = mediaItem.videoInfo {
        if let episode = videoInfo.episode {
          self.episode = episode
        }
        if videoInfo.episodeOrder != 0 {
          self.episodeOrder = videoInfo.episodeOrder
        }
        if videoInfo.isHD {
          self.hD = videoInfo.isHD
        }
        if videoInfo.season != 0 {
          self.season = videoInfo.season
        }
        if let series = videoInfo.series {
          self.series = series
        }
        if let sortSeries = videoInfo.sortSeries {
          self.sortSeries = sortSeries
        }
        if videoInfo.videoHeight != 0 {
          self.videoHeight = videoInfo.videoHeight
        }
        if videoInfo.videoWidth != 0 {
          self.videoWidth = videoInfo.videoWidth
        }
      }
    }
  }

  extension Track {
    static func gatherAllTracks() throws -> [Track] {
      let itunes = try ITLibrary(apiVersion: "1.1")
      return itunes.allMediaItems.map { Track($0) }
    }
  }
#endif
