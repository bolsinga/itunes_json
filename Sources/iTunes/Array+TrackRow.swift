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

extension Array where Element == TrackRow {
  var duplicatePlayDates: [TrackRow] {
    // group TrackRow by playdate. find those with more than one TrackRow and return those as a flat array.
    Dictionary(grouping: self.filter { $0.play != nil }) { $0.play!.date }.filter {
      $0.value.count > 1
    }.flatMap { $0.value }
  }
}
