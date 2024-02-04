//
//  Repair.swift
//
//
//  Created by Greg Bolsinga on 12/14/23.
//

import Foundation

public struct Repair {
  private let items: [Item]

  internal init(items: [Item]) {
    self.items = items
    //        items + [
    //          Item(problem: Problem(artist: nil, album: nil, name: nil, playCount: nil, playDate: nil),
    //            fix: Fix(album: nil, artist: nil, kind: nil, playCount: nil, sortArtist: nil, trackCount: nil,trackNumber: nil, year: nil, ignore: nil))
    //        ]
    //      do {
    //        try Repair.printRepairJson(items: self.items)
    //      } catch {}
  }

  func repair(_ tracks: [Track]) -> [Track] {
    fix(adjustDates(tracks)).filter { $0.isSQLEncodable }.map { $0.pruned }
  }

  private func adjustDates(_ tracks: [Track]) -> [Track] {
    tracks.datesAreAheadOneHour ? tracks.map { $0.moveDatesBackOneHour() } : tracks
  }

  internal func fix(_ tracks: [Track]) -> [Track] {
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

extension Repair {
  fileprivate enum RepairError: Error {
    case invalidInput
    case invalidString
  }

  public static func create(url: URL?, source: String?) async throws -> Repair {
    var items: [Item]?
    if let url { items = try await Repair.load(url: url) }
    if let source { items = try Repair.load(source: source) }
    if let items { return Repair(items: items) }
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

  private static func printRepairJson(items: [Item]) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(items)
    if let string = String(data: data, encoding: .utf8) {
      print(string)
    }
  }

  private static func load(data: Data) throws -> [Item] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let items = try decoder.decode([Item].self, from: data)
    return items
  }
}
