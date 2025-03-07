//
//  Collection+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

extension Collection where Element: Sendable {
  func changes<T: Sendable>(createChange: @escaping @Sendable (Element) -> [T]) async -> [T] {
    await withTaskGroup(of: Array<T>.self) { group in
      self.forEach { element in
        group.addTask { createChange(element) }
      }
      var changes: [T] = []
      for await change in group {
        changes.append(contentsOf: change)
      }
      return changes
    }
  }
}
