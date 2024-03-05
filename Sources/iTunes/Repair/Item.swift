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
    playDate: Date? = nil, persistentID: UInt? = nil
  ) {
    self.artist = artist
    self.album = album
    self.name = name
    self.playCount = playCount
    self.playDate = playDate
    self.persistentID = persistentID
  }

  let artist: String?
  let album: String?
  let name: String?
  let playCount: Int?
  let playDate: Date?
  let persistentID: UInt?
}

struct Fix: Codable {
  internal init(
    album: String? = nil, artist: String? = nil, kind: String? = nil, playCount: Int? = nil,
    playDate: Date? = nil, song: String? = nil, sortArtist: String? = nil, trackCount: Int? = nil,
    trackNumber: Int? = nil, year: Int? = nil, ignore: Bool? = nil, discCount: Int? = nil,
    discNumber: Int? = nil
  ) {
    self.album = album
    self.artist = artist
    self.kind = kind
    self.playCount = playCount
    self.playDate = playDate
    self.song = song
    self.sortArtist = sortArtist
    self.trackCount = trackCount
    self.trackNumber = trackNumber
    self.year = year
    self.ignore = ignore
    self.discCount = discCount
    self.discNumber = discNumber
  }

  let album: String?
  let artist: String?
  let kind: String?
  let playCount: Int?
  let playDate: Date?
  let song: String?
  let sortArtist: String?
  let trackCount: Int?
  let trackNumber: Int?
  let year: Int?
  let ignore: Bool?
  let discCount: Int?
  let discNumber: Int?
}

struct Item: Codable {
  let problem: Problem
  let fix: Fix
}
