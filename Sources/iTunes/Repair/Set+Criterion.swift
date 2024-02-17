//
//  Set+Criterion.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation

extension Set where Element == Criterion {
  fileprivate struct Qualifier: OptionSet {
    let rawValue: Int

    static let album = Qualifier(rawValue: 1 << 0)
    static let artist = Qualifier(rawValue: 1 << 1)
    static let song = Qualifier(rawValue: 1 << 2)
    static let playCount = Qualifier(rawValue: 1 << 3)
    static let playDate = Qualifier(rawValue: 1 << 4)
    static let persistentID = Qualifier(rawValue: 1 << 5)

    static let albumArtistSong: Qualifier = [.album, .artist, .song]
    static let artistSong: Qualifier = [.artist, .song]
    static let albumArtist: Qualifier = [.album, .artist]

    static let artistSongPlayCountPlayDate: Qualifier = [.artist, .song, .playCount, .playDate]
    static let artistSongPlayCount: Qualifier = [.artist, .song, .playCount]
  }

  fileprivate var qualifiers: Qualifier {
    self.reduce(into: Qualifier()) { partialResult, criteria in
      switch criteria {
      case .album(_):
        partialResult.insert(.album)
      case .artist(_):
        partialResult.insert(.artist)
      case .song(_):
        partialResult.insert(.song)
      case .playCount(_):
        partialResult.insert(.playCount)
      case .playDate(_):
        partialResult.insert(.playDate)
      case .persistentId(_):
        partialResult.insert(.persistentID)
      }
    }
  }

  var validForIgnore: Bool {
    let qualifiers = qualifiers
    return qualifiers == .artist || qualifiers == .song || qualifiers == .persistentID
  }

  var validForSortArtist: Bool {
    qualifiers == .artist
  }

  var validForKind: Bool {
    qualifiers == .albumArtistSong
  }

  var validForYear: Bool {
    let qualifiers = qualifiers
    return qualifiers.contains(.album)
      || qualifiers.intersection(Qualifier.artistSong) == Qualifier.artistSong
  }

  var validForTrackCount: Bool {
    // album or artist
    !qualifiers.intersection(Qualifier.albumArtist).isEmpty
  }

  var validForTrackNumber: Bool {
    // (song && artist) || (album && artist)
    let qualifiers = qualifiers
    return qualifiers.intersection(Qualifier.artistSong) == Qualifier.artistSong
      || qualifiers.intersection(Qualifier.albumArtist) == Qualifier.albumArtist
  }

  var validForAlbum: Bool {
    // artist or song
    !qualifiers.intersection(Qualifier.artistSong).isEmpty
  }

  var validForArtist: Bool {
    // artist or song
    !qualifiers.intersection(Qualifier.artistSong).isEmpty
  }

  var validForPlayCount: Bool {
    qualifiers.intersection(Qualifier.artistSongPlayCountPlayDate)
      == Qualifier.artistSongPlayCountPlayDate
  }

  var validForPlayDate: Bool {
    qualifiers.intersection(Qualifier.artistSongPlayCount)
      == Qualifier.artistSongPlayCount
  }
}
