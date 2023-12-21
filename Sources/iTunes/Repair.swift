//
//  Repair.swift
//
//
//  Created by Greg Bolsinga on 12/14/23.
//

import Foundation

struct Problem: Codable, Hashable {
  let artist: String?
  let album: String?
  let name: String?
}

struct Fix: Codable {
  let album: String?
  let artist: String?
  let kind: String?
  let sortArtist: String?
  let trackCount: Int?
  let trackNumber: Int?
  let year: Int?
  let ignore: Bool?
}

struct Item: Codable {
  let problem: Problem
  let fix: Fix
}

extension Fix {
  var trackIgnored: Bool {
    guard let ignore else { return false }
    return ignore
  }
}

extension Track {
  fileprivate var fixableAlbum: Bool {
    guard let album else { return true }
    return album.isEmpty
  }

  fileprivate var fixableYear: Bool {
    guard let year else { return true }
    return year <= 0
  }

  fileprivate var fixableTrackCount: Bool {
    guard let trackCount else { return true }
    return trackCount <= 0
  }

  fileprivate var fixableTrackNumber: Bool {
    guard let trackNumber else { return true }
    return trackNumber <= 0
  }

  fileprivate func repair(_ fix: Fix) -> Track? {
    guard !fix.trackIgnored else { return nil }

    let fixedAlbum = (self.fixableAlbum ? fix.album : nil) ?? self.album
    let fixedArtist = fix.artist ?? self.artist
    let fixedTrackCount = (self.fixableTrackCount ? fix.trackCount : nil) ?? self.trackCount
    let fixedTrackNumber = (self.fixableTrackNumber ? fix.trackNumber : nil) ?? self.trackNumber
    let fixedYear = (self.fixableYear ? fix.year : nil) ?? self.year

    let fixedSortArtist = {
      if let sortArtist = fix.sortArtist { return sortArtist.isEmpty ? nil : sortArtist }
      return self.sortArtist
    }()

    return Track(
      album: fixedAlbum, albumArtist: albumArtist, albumRating: albumRating,
      albumRatingComputed: albumRatingComputed, artist: fixedArtist, bitRate: bitRate, bPM: bPM,
      comments: comments, compilation: compilation, composer: composer,
      contentRating: contentRating, dateAdded: dateAdded, dateModified: dateModified,
      disabled: disabled, discCount: discCount, discNumber: discNumber, episode: episode,
      episodeOrder: episodeOrder, explicit: explicit, genre: genre, grouping: grouping,
      hasVideo: hasVideo, hD: hD, kind: fix.kind ?? kind, location: location, movie: movie,
      musicVideo: musicVideo, name: name, partOfGaplessAlbum: partOfGaplessAlbum,
      persistentID: persistentID, playCount: playCount, playDateUTC: playDateUTC,
      podcast: podcast, protected: protected, purchased: purchased, rating: rating,
      ratingComputed: ratingComputed, releaseDate: releaseDate, sampleRate: sampleRate,
      season: season, series: series, size: size, skipCount: skipCount, skipDate: skipDate,
      sortAlbum: sortAlbum, sortAlbumArtist: sortAlbumArtist, sortArtist: fixedSortArtist,
      sortComposer: sortComposer, sortName: sortName, sortSeries: sortSeries,
      totalTime: totalTime, trackCount: fixedTrackCount, trackNumber: fixedTrackNumber,
      trackType: trackType, tVShow: tVShow, unplayed: unplayed, videoHeight: videoHeight,
      videoWidth: videoWidth, year: fixedYear)
  }

  fileprivate func matches(problem: Problem) -> Bool {
    let artistMatch = {
      guard let artist = problem.artist else { return true }
      return artist == self.artist
    }()

    let albumMatch = {
      guard let album = problem.album else { return true }
      return album == self.album
    }()

    let nameMatch = {
      guard let name = problem.name else { return true }
      return name == self.name
    }()

    return artistMatch && albumMatch && nameMatch
  }
}

public struct Repair {
  let items: [Item]

  public func repair(_ tracks: [Track]) -> [Track] {
    let fixes = tracks.reduce(into: [Track: [Fix]]()) { dictionary, track in
      var arr = dictionary[track] ?? []
      arr.append(
        contentsOf: items.filter { track.matches(problem: $0.problem) }.compactMap { $0.fix })
      if !arr.isEmpty { dictionary[track] = arr }
    }

    guard !fixes.isEmpty else { return tracks }

    return tracks.compactMap { track in
      if let fixes = fixes[track], !fixes.isEmpty {
        var fixedTrack: Track? = track
        fixes.forEach {
          if let repairedTrack: Track = fixedTrack {
            fixedTrack = repairedTrack.repair($0)
          }
        }
        return fixedTrack
      }
      return track
    }
  }
}

enum RepairError: Error {
  case invalidInput
  case invalidString
}

extension Repair {
  public static func create(url: URL?, source: String?) async throws -> Repair {
    if let url { return Repair(items: try await Repair.load(url: url)) }
    if let source { return Repair(items: try Repair.load(source: source)) }
    throw RepairError.invalidInput
  }

  private static func load(source: String) throws -> [Item] {
    guard let data = source.data(using: .utf8) else { throw RepairError.invalidString }
    return try load(data: data)
  }

  private static func load(url: URL) async throws -> [Item] {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try load(data: data)
  }

  private static func load(data: Data) throws -> [Item] {
    let decoder = JSONDecoder()
    return try decoder.decode([Item].self, from: data)
  }
}
