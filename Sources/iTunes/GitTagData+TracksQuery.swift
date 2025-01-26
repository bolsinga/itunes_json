//
//  GitTagData+TracksQuery.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/25/25.
//

typealias TaggedTracks = Tag<[Track]>

extension GitTagData {
  func tracks(query: String, schemaOptions: SchemaOptions) async throws -> [TaggedTracks] {
    try await transformRows(query: query, schemaOptions: schemaOptions) { queryRows in
      queryRows.flatMap { $0.compactMap { Track(row: $0) } }
    }
  }

  func uniqueTracks(query: String, schemaOptions: SchemaOptions) async throws -> [TaggedTracks] {
    let tags = try await tracks(
      query: query, schemaOptions: schemaOptions
    ).sorted(by: { $0.tag < $1.tag })

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
