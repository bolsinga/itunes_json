//
//  Source.swift
//
//
//  Created by Greg Bolsinga on 10/30/23.
//

import Foundation

/// The source of the data to be converted into a Track.
enum Source: CaseIterable {
  /// Retreive Track data using the iTunesLibrary.
  case itunes
  /// Retreive Track data using MusicKit.
  case musickit
}
