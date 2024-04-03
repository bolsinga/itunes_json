//
//  GitBackupNameTests.swift
//
//
//  Created by Greg Bolsinga on 4/2/24.
//

import XCTest

@testable import iTunes

let PreviousName = "A"
let BasicName = "B"
let SubsequentName = "C"

final class GitBackupNameTests: XCTestCase {
  func test_noExisting() throws {
    XCTAssertEqual(
      "B-empty", GitBackup.noChanges.backupName(baseName: BasicName, existingNames: []))
    XCTAssertEqual("B", GitBackup.changes.backupName(baseName: BasicName, existingNames: []))
  }

  func testNoChanges_oneExisting() throws {
    XCTAssertEqual(
      "B.01-empty", GitBackup.noChanges.backupName(baseName: BasicName, existingNames: [BasicName]))
    XCTAssertEqual(
      "B.02-empty",
      GitBackup.noChanges.backupName(baseName: BasicName, existingNames: ["\(BasicName).01"]))
    XCTAssertEqual(
      "B-empty", GitBackup.noChanges.backupName(baseName: BasicName, existingNames: [PreviousName]))
  }

  func testChanges_oneExisting() throws {
    XCTAssertEqual(
      "B.01", GitBackup.changes.backupName(baseName: BasicName, existingNames: [BasicName]))
    XCTAssertEqual(
      "B.02", GitBackup.changes.backupName(baseName: BasicName, existingNames: ["\(BasicName).01"]))
    XCTAssertEqual(
      "B", GitBackup.changes.backupName(baseName: BasicName, existingNames: [PreviousName]))
  }

  func testNoChanges_multipleExisting() throws {
    XCTAssertEqual(
      "B.01-empty",
      GitBackup.noChanges.backupName(baseName: BasicName, existingNames: [PreviousName, BasicName]))
    XCTAssertEqual(
      "B.02-empty",
      GitBackup.noChanges.backupName(
        baseName: BasicName, existingNames: [PreviousName, BasicName, "\(BasicName).01"]))
    XCTAssertEqual(
      "B-empty",
      GitBackup.noChanges.backupName(
        baseName: BasicName, existingNames: [PreviousName, SubsequentName]))
    XCTAssertEqual(
      "B.01-empty",
      GitBackup.noChanges.backupName(
        baseName: BasicName, existingNames: [PreviousName, BasicName, SubsequentName]))
  }

  func testChanges_multipleExisting() throws {
    XCTAssertEqual(
      "B.01",
      GitBackup.changes.backupName(baseName: BasicName, existingNames: [PreviousName, BasicName]))
    XCTAssertEqual(
      "B.02",
      GitBackup.changes.backupName(
        baseName: BasicName, existingNames: [PreviousName, BasicName, "\(BasicName).01"]))
    XCTAssertEqual(
      "B",
      GitBackup.changes.backupName(
        baseName: BasicName, existingNames: [PreviousName, SubsequentName]))
    XCTAssertEqual(
      "B.01",
      GitBackup.changes.backupName(
        baseName: BasicName, existingNames: [PreviousName, BasicName, SubsequentName]))
  }
}
