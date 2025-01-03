//
//  TrackValidation.swift
//
//
//  Created by Greg Bolsinga on 3/9/24.
//

import Foundation
import os

struct TrackValidation {
  let noAlbum: Logger
  let noTrackCount: Logger
  let noArtist: Logger
  let noPlayDate: Logger
  let noPlayCount: Logger
  let invalidTrackNumber: Logger
  let noYear: Logger
  let duplicateArtist: Logger
  let duplicatePlayDate: Logger

  init(loggingToken: String?) {
    self.noAlbum = Logger(type: "validation", category: "noAlbum", token: loggingToken)
    self.noTrackCount = Logger(type: "validation", category: "noTrackCount", token: loggingToken)
    self.noArtist = Logger(type: "validation", category: "noArtist", token: loggingToken)
    self.noPlayDate = Logger(type: "validation", category: "noPlayDate", token: loggingToken)
    self.noPlayCount = Logger(type: "validation", category: "noPlayCount", token: loggingToken)
    self.invalidTrackNumber = Logger(
      type: "validation", category: "invalidTrackNumber", token: loggingToken)
    self.noYear = Logger(type: "validation", category: "noYear", token: loggingToken)
    self.duplicateArtist = Logger(
      type: "validation", category: "duplicateArtist", token: loggingToken)
    self.duplicatePlayDate = Logger(
      type: "validation", category: "duplicatePlayDate", token: loggingToken)
  }
}
