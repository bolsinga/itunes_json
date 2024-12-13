//
//  Artist+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

import Foundation

extension Array where Element == Track {
  var artistNames: Set<SortableName> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.artistName })
  }
}

func currentArtists() async throws -> Set<SortableName> {
  try await Source.itunes.gather(reduce: false).artistNames
}
