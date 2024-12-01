//
//  Collection+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

extension Collection where Element: Similar {
  func changes<T: Sendable>(createChange: @escaping @Sendable (Element) -> T) async -> [T] {
    await withTaskGroup(of: T.self) { group in
      self.forEach { element in
        group.addTask { createChange(element) }
      }
      var changes: [T] = []
      for await change in group {
        changes.append(change)
      }
      return changes
    }
  }
}
