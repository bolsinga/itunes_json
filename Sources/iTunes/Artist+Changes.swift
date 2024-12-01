//
//  Artist+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

import Foundation

extension Array where Element == Track {
  public var artistNames: Set<SortableName> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.artistName })
  }
}

public func currentArtists() async throws -> Set<SortableName> {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.artistNames
}
