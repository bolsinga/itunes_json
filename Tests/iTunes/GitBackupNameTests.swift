//
//  GitBackupNameTests.swift
//
//
//  Created by Greg Bolsinga on 4/2/24.
//

import Testing

@testable import iTunes

let previousName = "A"
// swift-format-ignore: AlwaysUseLowerCamelCase
let BasicName = "B"
let subsequentName = "C"

struct GitBackupNameTests {
  @Test func noExisting() {
    #expect("B-empty" == Backup.noChanges.backupName(baseName: BasicName, existingNames: []))
    #expect("B" == Backup.changes.backupName(baseName: BasicName, existingNames: []))
  }

  @Test func noChanges_oneExisting() {
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(baseName: BasicName, existingNames: [BasicName]))
    #expect(
      "B.02-empty"
        == Backup.noChanges.backupName(baseName: BasicName, existingNames: ["\(BasicName).01"]))
    #expect(
      "B-empty"
        == Backup.noChanges.backupName(baseName: BasicName, existingNames: [previousName]))
  }

  @Test func changes_oneExisting() {
    #expect("B.01" == Backup.changes.backupName(baseName: BasicName, existingNames: [BasicName]))
    #expect(
      "B.02"
        == Backup.changes.backupName(baseName: BasicName, existingNames: ["\(BasicName).01"]))
    #expect("B" == Backup.changes.backupName(baseName: BasicName, existingNames: [previousName]))
  }

  @Test func noChanges_multipleExisting() {
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName]))
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName, "\(BasicName)-empty"]))
    #expect(
      "B.02-empty"
        == Backup.noChanges.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName, "\(BasicName).01-empty"]))
    #expect(
      "B.02-empty"
        == Backup.noChanges.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName, "\(BasicName).01"]))
    #expect(
      "B-empty"
        == Backup.noChanges.backupName(
          baseName: BasicName, existingNames: [previousName, subsequentName]))
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName, subsequentName]))
  }

  @Test func changes_multipleExisting() {
    #expect(
      "B.01"
        == Backup.changes.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName]))
    #expect(
      "B.02"
        == Backup.changes.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName, "\(BasicName).01"]))
    #expect(
      "B"
        == Backup.changes.backupName(
          baseName: BasicName, existingNames: [previousName, subsequentName]))
    #expect(
      "B.01"
        == Backup.changes.backupName(
          baseName: BasicName, existingNames: [previousName, BasicName, subsequentName]))
  }

  @Test func newstuff() {
    #expect(
      "iTunes.artists-2024-12-11.02"
        == Backup.changes.backupName(
          baseName: "iTunes.artists-2024-12-11",
          existingNames: ["iTunes.artists-2024-12-11", "iTunes.artists-2024-12-11.01"]))
  }
}
