//
//  Repair+Load.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation

extension Repair {
  fileprivate enum RepairError: Error {
    case invalidInput
    case invalidString
  }

  public static func create(url: URL?, source: String?) async throws -> Repair {
    var items: [Item]?
    if let url { items = try await Repair.load(url: url) }
    if let source { items = try Repair.load(source: source) }
    if let items {
      let issues = items.compactMap { $0.issue }
      if items.count != issues.count {
        print("items: \(items.count) issues: \(issues.count)")
      }
      //      do {
      //        try Repair.printRepairJson(items: items)
      //      } catch {}
      return Repair(items: items)
    }
    throw RepairError.invalidInput
  }

  private static func load(source: String) throws -> [Item] {
    guard let data = source.data(using: .utf8) else { throw RepairError.invalidString }
    return try load(data: data)
  }

  private static func load(url: URL) async throws -> [Item] {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try load(data: data)
  }

  private static func printRepairJson(items: [Item]) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(items)
    if let string = String(data: data, encoding: .utf8) {
      print(string)
    }
  }

  private static func load(data: Data) throws -> [Item] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let items = try decoder.decode([Item].self, from: data)
    return items
  }
}
