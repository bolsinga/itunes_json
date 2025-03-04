//
//  IdentifierCorrection+Row.swift
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

  fileprivate var duration: IdentifierCorrection.Correction? {
    .duration(integerValue)
  }

  fileprivate var persistentID: IdentifierCorrection.Correction? {
    guard let value = stringValue, let id = UInt(value) else { return nil }
    return .persistentID(id)
  }

  fileprivate var dateAdded: IdentifierCorrection.Correction? {
    .dateAdded(date)
  }

  fileprivate var composer: IdentifierCorrection.Correction? {
    guard let value = stringValue else { return nil }
    return .composer(value)
  }

  fileprivate var comments: IdentifierCorrection.Correction? {
    guard let value = stringValue else { return nil }
    return .comments(value)
  }

  fileprivate var dateReleased: IdentifierCorrection.Correction? {
    .dateReleased(date)
  }

  fileprivate var albumTitle: IdentifierCorrection.Correction? {
    .albumTitle(sortableName)
  }

  fileprivate var year: IdentifierCorrection.Correction? {
    guard let value = integerValue else { return nil }
    return .year(value)
  }

  fileprivate var trackNumber: IdentifierCorrection.Correction? {
    guard let value = integerValue else { return nil }
    return .trackNumber(value)
  }

  fileprivate var replaceSongTitle: IdentifierCorrection.Correction? {
    guard let sortableName else { return nil }
    return .replaceSongTitle(sortableName)
  }

  fileprivate var discCount: IdentifierCorrection.Correction? {
    guard let value = integerValue else { return nil }
    return .discCount(value)
  }

  fileprivate var discNumber: IdentifierCorrection.Correction? {
    guard let value = integerValue else { return nil }
    return .discNumber(value)
  }

  fileprivate var artist: IdentifierCorrection.Correction? {
    .artist(sortableName)
  }

  fileprivate var play: IdentifierCorrection.Correction? {
    .play(old: oldPlay, new: newPlay)
  }
}

extension IdentifierCorrection {
  init?(row: Database.Row, property: (DatabaseRowLookup) -> Correction?) {
    let lookup = DatabaseRowLookup(row: row)

    guard let itunesid = lookup.itunesid else { return nil }
    guard let property = property(lookup) else { return nil }

    self.init(persistentID: itunesid, correction: property)
  }

  static func duration(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.duration }
  }

  static func persistentID(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.persistentID }
  }

  static func dateAdded(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.dateAdded }
  }

  static func composer(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.composer }
  }

  static func comments(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.comments }
  }

  static func dateReleased(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.dateReleased }
  }

  static func albumTitle(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.albumTitle }
  }

  static func year(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.year }
  }

  static func trackNumber(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.trackNumber }
  }

  static func replaceSongTitle(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.replaceSongTitle }
  }

  static func discCount(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.discCount }
  }

  static func discNumber(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.discNumber }
  }

  static func artist(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.artist }
  }

  static func play(row: Database.Row) -> IdentifierCorrection? {
    self.init(row: row) { $0.play }
  }
}
