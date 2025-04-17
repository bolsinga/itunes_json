//
//  Track+TrackRow.swift
//
//
//  Created by Greg Bolsinga on 2/16/24.
//

import Foundation

extension Track {
  func trackRow(_ validation: TrackValidation) -> TrackRow {
    TrackRow(
      album: RowAlbum(self, validation: validation),
      artist: RowArtist(self, validation: validation), song: RowSong(self, validation: validation),
      play: RowPlay(self, validation: validation), add: RowAdd(self), release: RowRelease(self))
  }
}
