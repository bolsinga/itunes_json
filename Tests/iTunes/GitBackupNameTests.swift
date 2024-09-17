//
//  GitBackupNameTests.swift
//
//
//  Created by Greg Bolsinga on 4/2/24.
//

import Testing

@testable import iTunes

let PreviousName = "A"
let BasicName = "B"
let SubsequentName = "C"

struct GitBackupNameTests {
  @Test func noExisting() {
    #expect("B-empty" == GitBackup.noChanges.backupName(baseName: BasicName, existingNames: []))
    #expect("B" == GitBackup.changes.backupName(baseName: BasicName, existingNames: []))
  }

  @Test func noChanges_oneExisting() {
    #expect(
      "B.01-empty"
        == GitBackup.noChanges.backupName(baseName: BasicName, existingNames: [BasicName]))
    #expect(
      "B.02-empty"
        == GitBackup.noChanges.backupName(baseName: BasicName, existingNames: ["\(BasicName).01"]))
    #expect(
      "B-empty"
        == GitBackup.noChanges.backupName(baseName: BasicName, existingNames: [PreviousName]))
  }

  @Test func changes_oneExisting() {
    #expect("B.01" == GitBackup.changes.backupName(baseName: BasicName, existingNames: [BasicName]))
    #expect(
      "B.02"
        == GitBackup.changes.backupName(baseName: BasicName, existingNames: ["\(BasicName).01"]))
    #expect("B" == GitBackup.changes.backupName(baseName: BasicName, existingNames: [PreviousName]))
  }

  @Test func noChanges_multipleExisting() {
    #expect(
      "B.01-empty"
        == GitBackup.noChanges.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName]))
    #expect(
      "B.01-empty"
        == GitBackup.noChanges.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName, "\(BasicName)-empty"]))
    #expect(
      "B.02-empty"
        == GitBackup.noChanges.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName, "\(BasicName).01-empty"]))
    #expect(
      "B.02-empty"
        == GitBackup.noChanges.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName, "\(BasicName).01"]))
    #expect(
      "B-empty"
        == GitBackup.noChanges.backupName(
          baseName: BasicName, existingNames: [PreviousName, SubsequentName]))
    #expect(
      "B.01-empty"
        == GitBackup.noChanges.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName, SubsequentName]))
  }

  @Test func changes_multipleExisting() {
    #expect(
      "B.01"
        == GitBackup.changes.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName]))
    #expect(
      "B.02"
        == GitBackup.changes.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName, "\(BasicName).01"]))
    #expect(
      "B"
        == GitBackup.changes.backupName(
          baseName: BasicName, existingNames: [PreviousName, SubsequentName]))
    #expect(
      "B.01"
        == GitBackup.changes.backupName(
          baseName: BasicName, existingNames: [PreviousName, BasicName, SubsequentName]))
  }
}
