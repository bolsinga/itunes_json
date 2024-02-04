//
//  Item.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation

struct Problem: Codable, Hashable {
  let artist: String?
  let album: String?
  let name: String?
  let playCount: Int?
  let playDate: Date?
}

struct Fix: Codable {
  let album: String?
  let artist: String?
  let kind: String?
  let playCount: Int?
  let playDate: Date?
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
