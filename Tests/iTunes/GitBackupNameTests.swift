//
//  GitBackupNameTests.swift
//
//
//  Created by Greg Bolsinga on 4/2/24.
//

import Testing

@testable import iTunes

// swift-format-ignore: AlwaysUseLowerCamelCase
let PreviousName = "A"
let basicName = "B"
// swift-format-ignore: AlwaysUseLowerCamelCase
let SubsequentName = "C"

struct GitBackupNameTests {
  @Test func noExisting() {
    #expect("B-empty" == Backup.noChanges.backupName(baseName: basicName, existingNames: []))
    #expect("B" == Backup.changes.backupName(baseName: basicName, existingNames: []))
  }

  @Test func noChanges_oneExisting() {
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(baseName: basicName, existingNames: [basicName]))
    #expect(
      "B.02-empty"
        == Backup.noChanges.backupName(baseName: basicName, existingNames: ["\(basicName).01"]))
    #expect(
      "B-empty"
        == Backup.noChanges.backupName(baseName: basicName, existingNames: [PreviousName]))
  }

  @Test func changes_oneExisting() {
    #expect("B.01" == Backup.changes.backupName(baseName: basicName, existingNames: [basicName]))
    #expect(
      "B.02"
        == Backup.changes.backupName(baseName: basicName, existingNames: ["\(basicName).01"]))
    #expect("B" == Backup.changes.backupName(baseName: basicName, existingNames: [PreviousName]))
  }

  @Test func noChanges_multipleExisting() {
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName]))
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName, "\(basicName)-empty"]))
    #expect(
      "B.02-empty"
        == Backup.noChanges.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName, "\(basicName).01-empty"]))
    #expect(
      "B.02-empty"
        == Backup.noChanges.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName, "\(basicName).01"]))
    #expect(
      "B-empty"
        == Backup.noChanges.backupName(
          baseName: basicName, existingNames: [PreviousName, SubsequentName]))
    #expect(
      "B.01-empty"
        == Backup.noChanges.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName, SubsequentName]))
  }

  @Test func changes_multipleExisting() {
    #expect(
      "B.01"
        == Backup.changes.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName]))
    #expect(
      "B.02"
        == Backup.changes.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName, "\(basicName).01"]))
    #expect(
      "B"
        == Backup.changes.backupName(
          baseName: basicName, existingNames: [PreviousName, SubsequentName]))
    #expect(
      "B.01"
        == Backup.changes.backupName(
          baseName: basicName, existingNames: [PreviousName, basicName, SubsequentName]))
  }

  @Test func newstuff() {
    #expect(
      "iTunes.artists-2024-12-11.02"
        == Backup.changes.backupName(
          baseName: "iTunes.artists-2024-12-11",
          existingNames: ["iTunes.artists-2024-12-11", "iTunes.artists-2024-12-11.01"]))
  }
}
