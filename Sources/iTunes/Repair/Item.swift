//
//  Item.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation

struct Problem: Codable, Hashable {
  internal init(
    artist: String? = nil, album: String? = nil, name: String? = nil, playCount: Int? = nil,
    playDate: Date? = nil
  ) {
    self.artist = artist
    self.album = album
    self.name = name
    self.playCount = playCount
    self.playDate = playDate
  }

  let artist: String?
  let album: String?
  let name: String?
  let playCount: Int?
  let playDate: Date?
}

struct Fix: Codable {
  internal init(
    album: String? = nil, artist: String? = nil, kind: String? = nil, playCount: Int? = nil,
    playDate: Date? = nil, sortArtist: String? = nil, trackCount: Int? = nil,
    trackNumber: Int? = nil, year: Int? = nil, ignore: Bool? = nil
  ) {
    self.album = album
    self.artist = artist
    self.kind = kind
    self.playCount = playCount
    self.playDate = playDate
    self.sortArtist = sortArtist
    self.trackCount = trackCount
    self.trackNumber = trackNumber
    self.year = year
    self.ignore = ignore
  }

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
