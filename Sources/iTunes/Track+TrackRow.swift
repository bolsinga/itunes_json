//
//  Track+TrackRow.swift
//
//
//  Created by Greg Bolsinga on 2/16/24.
//

import Foundation

extension Track {
  func trackRow(_ loggingToken: String?) -> TrackRow {
    TrackRow(
      album: RowAlbum(self), artist: RowArtist(self), song: RowSong(self),
      play: RowPlay(self, loggingToken: loggingToken))
  }
}
