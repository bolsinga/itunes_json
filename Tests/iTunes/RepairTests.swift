//
//  RepairTests.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation
import XCTest

@testable import iTunes

final class RepairTests: XCTestCase {
  private func createTrack(_ jsonString: String) -> Track {
    guard let data = jsonString.data(using: .utf8) else { preconditionFailure() }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    var result: Track
    do {
      result = try decoder.decode(Track.self, from: data)
    } catch {
      preconditionFailure()
    }
    return result
  }

  private func createItem(_ jsonString: String) -> Item {
    guard let data = jsonString.data(using: .utf8) else { preconditionFailure() }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    var result: Item
    do {
      result = try decoder.decode(Item.self, from: data)
    } catch {
      preconditionFailure()
    }
    return result
  }

  func testKind() throws {
    let animalsiTunesLP = """
      {
        "album" : "Animals",
        "artist" : "Pink Floyd",
        "dateAdded" : "2023-07-10T01:56:35Z",
        "dateModified" : "2023-07-10T01:56:37Z",
        "genre" : "Rock",
        "name" : "Animals - iTunes LP",
        "persistentID" : 9261125880940887250,
        "playCount" : 0,
        "sampleRate" : 0,
        "size" : 3642150,
        "sortAlbum" : "Animals",
        "sortArtist" : "Pink Floyd",
        "sortName" : "Animals - iTunes LP",
        "totalTime" : 0,
        "trackNumber" : 0,
        "trackType" : "Remote",
        "year" : 0
      }
      """
    let animalsKindItem = """
      {
        "fix" : {
          "kind" : "iTunes LP"
        },
        "problem" : {
          "album" : "Animals",
          "artist" : "Pink Floyd",
          "name" : "Animals - iTunes LP"
        }
      }
      """
    let track = createTrack(animalsiTunesLP)
    XCTAssertNil(track.kind)

    let item = createItem(animalsKindItem)
    XCTAssertTrue(track.matches(problem: item.problem))

    let repair = Repair(items: [item])

    // This will fix the kind...
    let fixed = repair.fix([track])
    XCTAssertEqual(fixed.count, 1)
    XCTAssertNotNil(fixed[0].kind)

    // ...but it is not encodable...
    XCTAssertFalse(fixed[0].isSQLEncodable)

    // ...so it does not exist once repaired.
    let repaired = repair.repair([track])
    XCTAssertEqual(repaired.count, 0)
  }

  func testIgnored_exclusive() throws {
    let ignoreItem = """
      {
        "fix" : {
          "ignore" : true
        },
        "problem" : {
          "artist" : "Pink Floyd",
        }
      }
      """
    var item = createItem(ignoreItem)
    XCTAssertTrue(item.fix.validateIgnoreFix)
    XCTAssertTrue(item.fix.trackIgnored)

    let ignoreItem2 = """
      {
        "fix" : {
          "ignore" : true,
          "year": 1970
        },
        "problem" : {
          "artist" : "Pink Floyd",
        }
      }
      """
    item = createItem(ignoreItem2)
    XCTAssertFalse(item.fix.validateIgnoreFix)
  }
}
