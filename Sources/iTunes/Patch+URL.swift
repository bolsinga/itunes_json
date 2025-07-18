//
//  Patch+URL.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/25/25.
//

import Foundation

extension Array where Element: Codable {
  static fileprivate func load(from url: URL) throws -> Self {
    try load(from: try Data(contentsOf: url, options: .mappedIfSafe))
  }

  static fileprivate func load(from data: Data) throws -> Self {
    let decoder = JSONDecoder()
    return try decoder.decode(Self.self, from: data)
  }
}

private enum PatchType {
  case unknown
  case json
  case database
}

extension URL {
  fileprivate var patchType: PatchType {
    switch pathExtension {
    case "json":
      .json
    case "db":
      .database
    default:
      .unknown
    }
  }

  fileprivate func database() throws -> Database {
    try Database(context: Database.Context(storage: .file(self), loggingToken: nil))
  }

  fileprivate func repairs() async throws -> [IdentityRepair] {
    enum CorrectionsError: Error {
      case unknownPatchFileType
    }
    switch patchType {
    case .unknown:
      throw CorrectionsError.unknownPatchFileType
    case .json:
      return try Array<IdentityRepair>.load(from: self)
    case .database:
      return try await database().identityRepairs()
    }
  }
}

extension Patch {
  static func load(_ url: URL) async throws -> Patch {
    .identityRepairs(try await url.repairs())
  }
}
