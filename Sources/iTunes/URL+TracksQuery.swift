//
//  URL+TracksQuery.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/25/25.
//

import Foundation

typealias TaggedTracks = Tag<[Track]>

extension URL {
  fileprivate func tracks(query: String, format: DatabaseFormat) async throws -> [TaggedTracks] {
    try await transformRows(query: query, format: format) { queryRows in
      queryRows.flatMap { $0.compactMap { Track(row: $0) } }
    }.reduce(into: [TaggedTracks]()) {
      $0.append($1)
    }
  }

  func uniqueTracks(query: String, format: DatabaseFormat) async throws -> [TaggedTracks] {
    let tags = try await tracks(query: query, format: format).sorted(by: {
      $0.tag < $1.tag
    })

    // each unique Track will refer to the tags it is in; the tags are in-order.
    let trackToTags = tags.reduce(into: [Track: [String]]()) { partialResult, tag in
      partialResult = tag.item.reduce(into: partialResult) { partialResult, track in
        var tags = partialResult[track] ?? []
        tags.append(tag.tag)
        partialResult[track] = tags
      }
    }

    // each tag will have a list of the tracks that first appear in the tag
    let tagToTracks = trackToTags.reduce(into: [String: [Track]]()) { partialResult, value in
      let (track, tags) = value

      let firstTag = tags.first!

      var tracks = partialResult[firstTag] ?? []
      tracks.append(track)
      partialResult[firstTag] = tracks
    }

    // make them back into Tags
    return tagToTracks.map { Tag(tag: $0.key, item: $0.value) }.sorted(by: { $0.tag < $1.tag })
  }
}
