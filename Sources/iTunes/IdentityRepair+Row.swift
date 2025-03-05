//
//  IdentityRepair+Row.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/25/25.
//

import Foundation

extension DatabaseRowLookup {
  fileprivate var itunesid: UInt? { if let v = string("itunesid") { UInt(v) } else { nil } }

  fileprivate var name: String? { string("name") }
  fileprivate var sort: String? { string("sort") }

  fileprivate var sortableName: SortableName? {
    guard let name else { return nil }
    return SortableName(name: name, sorted: sort ?? "")
  }

  fileprivate var integerValue: Int? { integer("value") }
  fileprivate var stringValue: String? { string("value") }

  fileprivate var date: Date? { date("date") }

  fileprivate var oldPlay: Play { Play(date: date("olddate"), count: integer("oldcount")) }
  fileprivate var newPlay: Play { Play(date: date("newdate"), count: integer("newcount")) }

  fileprivate var duration: IdentityRepair.Correction? {
    .duration(integerValue)
  }

  fileprivate var persistentID: IdentityRepair.Correction? {
    guard let value = stringValue, let id = UInt(value) else { return nil }
    return .persistentID(id)
  }

  fileprivate var dateAdded: IdentityRepair.Correction? {
    .dateAdded(date)
  }

  fileprivate var composer: IdentityRepair.Correction? {
    guard let value = stringValue else { return nil }
    return .composer(value)
  }

  fileprivate var comments: IdentityRepair.Correction? {
    guard let value = stringValue else { return nil }
    return .comments(value)
  }

  fileprivate var dateReleased: IdentityRepair.Correction? {
    .dateReleased(date)
  }

  fileprivate var albumTitle: IdentityRepair.Correction? {
    .albumTitle(sortableName)
  }

  fileprivate var year: IdentityRepair.Correction? {
    guard let value = integerValue else { return nil }
    return .year(value)
  }

  fileprivate var trackNumber: IdentityRepair.Correction? {
    guard let value = integerValue else { return nil }
    return .trackNumber(value)
  }

  fileprivate var replaceSongTitle: IdentityRepair.Correction? {
    guard let sortableName else { return nil }
    return .replaceSongTitle(sortableName)
  }

  fileprivate var discCount: IdentityRepair.Correction? {
    guard let value = integerValue else { return nil }
    return .discCount(value)
  }

  fileprivate var discNumber: IdentityRepair.Correction? {
    guard let value = integerValue else { return nil }
    return .discNumber(value)
  }

  fileprivate var artist: IdentityRepair.Correction? {
    .artist(sortableName)
  }

  fileprivate var play: IdentityRepair.Correction? {
    .play(old: oldPlay, new: newPlay)
  }
}

extension IdentityRepair {
  init?(row: Database.Row, correctionLookup: (DatabaseRowLookup) -> Correction?) {
    let lookup = DatabaseRowLookup(row: row)

    guard let itunesid = lookup.itunesid else { return nil }
    guard let correction = correctionLookup(lookup) else { return nil }

    self.init(persistentID: itunesid, correction: correction)
  }

  static func duration(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.duration }
  }

  static func persistentID(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.persistentID }
  }

  static func dateAdded(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.dateAdded }
  }

  static func composer(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.composer }
  }

  static func comments(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.comments }
  }

  static func dateReleased(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.dateReleased }
  }

  static func albumTitle(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.albumTitle }
  }

  static func year(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.year }
  }

  static func trackNumber(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.trackNumber }
  }

  static func replaceSongTitle(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.replaceSongTitle }
  }

  static func discCount(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.discCount }
  }

  static func discNumber(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.discNumber }
  }

  static func artist(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.artist }
  }

  static func play(row: Database.Row) -> IdentityRepair? {
    self.init(row: row) { $0.play }
  }
}
