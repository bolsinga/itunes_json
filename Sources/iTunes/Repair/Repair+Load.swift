//
//  Repair+Load.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation
import os

extension Logger {
  static let duplicateProblem = Logger(subsystem: "repair", category: "duplicateProblem")
}

private enum RepairError: Error {
  case invalidInput
  case invalidString
}

public func createRepair(url: URL?, source: String?) async throws -> Repairing {
  var items: [Item]?
  if let url { items = try await load(url: url) }
  if let source { items = try load(source: source) }
  if let items {
    let duplicateProblems = Dictionary(grouping: items.compactMap { $0.problem }) { $0 }.filter {
      $1.count > 1
    }
    .keys
    duplicateProblems.forEach {
      Logger.duplicateProblem.error("\(String(describing: $0), privacy: .public)")
    }
    //      do {
    //        try printRepairJson(items: items)
    //      } catch {}

    let issues = items.compactMap { $0.issue }
    return Repair(issues: issues)
  }
  throw RepairError.invalidInput
}

private func load(source: String) throws -> [Item] {
  guard let data = source.data(using: .utf8) else { throw RepairError.invalidString }
  return try load(data: data)
}

private func load(url: URL) async throws -> [Item] {
  let (data, _) = try await URLSession.shared.data(from: url)
  return try load(data: data)
}

private func printRepairJson(items: [Item]) throws {
  let data = try items.jsonData()
  if let string = String(data: data, encoding: .utf8) {
    print(string)
  }
}

private func load(data: Data) throws -> [Item] {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  let items = try decoder.decode([Item].self, from: data)
  return items
}
