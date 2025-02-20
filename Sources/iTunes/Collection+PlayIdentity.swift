//
//  Collection+PlayIdentity.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/19/25.
//

import Foundation
import os

extension Logger {
  fileprivate static let play = Logger(category: "play")
}

extension Dictionary where Key == UInt, Value == [PlayIdentity] {
  func relevantChanges() -> [IdentifierCorrection] {
    let oldPlays = self.mapValues { $0.map { $0.play } }
    let normalized = oldPlays.mapValues { $0.normalize() }
    let newPlays = normalized.mapValues { $0.0 }

    let checks = normalized.mapValues { $0.1 }

    guard oldPlays.count == newPlays.count else { return [] }

    return zip(oldPlays, newPlays).reduce(into: [IdentifierCorrection]()) {
      (
        partialResult: inout [IdentifierCorrection],
        item: (Dictionary<UInt, [Play]>.Element, Dictionary<UInt, [Play]>.Element)
      ) in
      let persistentID = item.0.key
      let oldPlays = item.0.value
      let newPlays = item.1.value

      guard oldPlays != newPlays else {
        Logger.play.info("No Change: \(persistentID)")
        return
      }
      guard oldPlays.count == newPlays.count else {
        Logger.play.info(
          "Cannot Normalize: \(persistentID) old: \(oldPlays.count) new: \(newPlays.count) check: \(checks[persistentID] ?? "n/a")"
        )
        return
      }

      partialResult = zip(oldPlays, newPlays).reduce(into: partialResult) {
        (partialResult: inout [IdentifierCorrection], item: (Play, Play)) in
        let (old, new) = item
        guard old != new else { return }
        partialResult.append(
          IdentifierCorrection(
            persistentID: persistentID, correction: .play(old: old, new: new)))
      }
    }
  }
}
