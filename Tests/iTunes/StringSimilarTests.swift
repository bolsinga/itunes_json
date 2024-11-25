//
//  StringSimilarTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/25/24.
//

import Testing

@testable import iTunes

struct StringSimilarTests {
  @Test(
    "Similarity",
    arguments: zip(
      [
        "3D's", "Oh Sees ", "The B-52's", "TORRES", "OFF!", "Matt Sweeney & Bonnie 'Prince' Billy",
        "Bonnie \"Prince\" Billy",
      ],
      [
        "3Ds", "OhSees", "B52s", "TORRES", "OFF", "MattSweeneyBonniePrinceBilly",
        "BonniePrinceBilly",
      ]))
  func trimForSimilariity(original: String, expected: String) async throws {
    #expect(original.trimmedForSimilarity == expected)
  }

  @Test(
    "IsSimilarTo",
    arguments: zip(
      [
        "3D's", "3D's", "Oh Sees ", "The B-52's", "The B-52's", "TORRES", "OFF!",
        "Matt Sweeney & Bonnie 'Prince' Billy",
        "Bonnie \"Prince\" Billy", "Bonnie \"Prince\" Billy",
      ],
      [
        "The 3D's", "The 3Ds", "Oh Sees ", "B-52's", "B52's", "Torres", "OFF",
        "Matt Sweeney & Bonnie 'Prince' Billy",
        "Bonnie \"Prince\" Billy", "Bonnie 'Prince' Billy",
      ]))
  func isSimilarTo(original: String, other: String) async throws {
    #expect(original.isSimilar(to: other))
  }
}
