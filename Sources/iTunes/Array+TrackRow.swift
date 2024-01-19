//
//  Array+TrackRow.swift
//
//
//  Created by Greg Bolsinga on 1/18/24.
//

import Foundation

extension Track {
  fileprivate var trackRow: TrackRow {
    TrackRow(
      album: RowAlbum(self), artist: RowArtist(self), song: RowSong(self), play: RowPlay(self))
  }
}

extension Array where Element == Track {
  var rowEncoder: TrackRowEncoder {
    TrackRowEncoder(rows: self.filter { $0.isSQLEncodable }.map { $0.trackRow })
  }
}
