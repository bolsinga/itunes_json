//
//  Collection+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

extension Collection where Element: Similar {
  public func changes<T: Sendable>(createChange: @escaping @Sendable (Element) -> T?) async -> [T] {
    await withTaskGroup(of: Optional<T>.self) { group in
      self.forEach { element in
        group.addTask { createChange(element) }
      }
      var changes: [T] = []
      for await change in group {
        guard let change = change else { continue }
        changes.append(change)
      }
      return changes
    }
  }
}
