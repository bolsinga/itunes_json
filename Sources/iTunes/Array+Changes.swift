//
//  Array+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

extension Array where Element: Sendable {
  func changes<T: Sendable>(createChange: @escaping @Sendable (Element) -> [T]) async -> [T] {
    await withTaskGroup(of: Array<T>.self) { group in
      self.forEach { element in
        group.addTask { createChange(element) }
      }
      return await group.reduce(into: [T]()) { $0.append(contentsOf: $1) }
    }
  }
}
