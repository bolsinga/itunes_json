//
//  Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import iTunes

enum Patch {
  case artists([ArtistPatch])
  case albums([AlbumPatch])
}
