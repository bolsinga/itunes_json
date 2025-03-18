//
//  URL+Read+TagData.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import GitLibrary

extension URL {
  func tagDatum() async throws -> [Tag<Data>] {
    let git = Git(directory: self.parentDirectory, suppressStandardErr: true)

    try await git.status()

    var tagDatum: [Tag<Data>] = []
    for try await tagData in TagSequence(
      tags: try await git.tags().stampOrderedMatching,
      dataProvider: {
        try await git.show(commit: $0, path: self.filename)
      })
    {
      tagDatum.append(tagData)
    }
    return tagDatum
  }
}
