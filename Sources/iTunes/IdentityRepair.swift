//
//  IdentityRepair.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/2/25.
//

import Foundation

struct IdentityRepair: Codable, Comparable, Hashable, Identifiable, Sendable {
  enum Correction: Codable, Comparable, Hashable, Sendable {
    case duration(Int?)
    case persistentID(UInt)
    case dateAdded(String?)
    case composer(String)
    case comments(String)
    case dateReleased(String?)
    case albumTitle(SortableName?)
    case year(Int)
    case trackNumber(Int)
    case replaceSongTitle(SortableName)
    case discCount(Int)
    case discNumber(Int)
    case artist(SortableName?)
    case play(old: Play, new: Play)

    static func < (lhs: IdentityRepair.Correction, rhs: IdentityRepair.Correction)
      -> Bool
    {
      switch (lhs, rhs) {
      case (.duration(let lhv), .duration(let rhv)):
        return lhv < rhv
      case (.persistentID(let lhv), .persistentID(let rhv)):
        return lhv < rhv
      case (.dateAdded(let lhv), .dateAdded(let rhv)):
        return lhv < rhv
      case (.composer(let lhv), .composer(let rhv)):
        return lhv < rhv
      case (.comments(let lhv), .comments(let rhv)):
        return lhv < rhv
      case (.dateReleased(let lhv), .dateReleased(let rhv)):
        return lhv < rhv
      case (.albumTitle(let lhv), .albumTitle(let rhv)):
        return lhv < rhv
      case (.year(let lhv), .year(let rhv)):
        return lhv < rhv
      case (.trackNumber(let lhv), .trackNumber(let rhv)):
        return lhv < rhv
      case (.replaceSongTitle(let lhv), .replaceSongTitle(let rhv)):
        return lhv < rhv
      case (.discCount(let lhv), .discCount(let rhv)):
        return lhv < rhv
      case (.discNumber(let lhv), .discNumber(let rhv)):
        return lhv < rhv
      case (.artist(let lhv), .artist(let rhv)):
        return lhv < rhv
      case (.play(let lho, let lhn), .play(let rho, let rhn)):
        if lhn == rhn {
          return lho < rho
        }
        return lhn < rhn
      default:
        return false
      }
    }

    func isValueDifferent(from other: Correction) -> Bool {
      switch (self, other) {
      case (.duration(let lhv), .duration(let rhv)):
        return lhv != rhv
      case (.persistentID(let lhv), .persistentID(let rhv)):
        return lhv != rhv
      case (.dateAdded(let lhv), .dateAdded(let rhv)):
        return lhv != rhv
      case (.composer(let lhv), .composer(let rhv)):
        return lhv != rhv
      case (.comments(let lhv), .comments(let rhv)):
        return lhv != rhv
      case (.dateReleased(let lhv), .dateReleased(let rhv)):
        return lhv != rhv
      case (.albumTitle(let lhv), .albumTitle(let rhv)):
        return lhv != rhv
      case (.year(let lhv), .year(let rhv)):
        return lhv != rhv
      case (.trackNumber(let lhv), .trackNumber(let rhv)):
        return lhv != rhv
      case (.replaceSongTitle(let lhv), .replaceSongTitle(let rhv)):
        return lhv != rhv
      case (.discCount(let lhv), .discCount(let rhv)):
        return lhv != rhv
      case (.discNumber(let lhv), .discNumber(let rhv)):
        return lhv != rhv
      case (.artist(let lhv), .artist(let rhv)):
        return lhv != rhv
      case (.play(let lho, let lhn), .play(let rho, let rhn)):
        if lho == rho {
          return lhn != rhn
        }
        return false
      default:
        return false
      }
    }
  }

  let persistentID: UInt
  let correction: Correction

  var id: UInt { persistentID }

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.persistentID == rhs.persistentID {
      return lhs.correction < rhs.correction
    }
    return lhs.persistentID < rhs.persistentID
  }

  func isCorrectionValueDifferent(from other: IdentityRepair) -> Bool {
    guard persistentID == other.persistentID else { return false }
    return correction.isValueDifferent(from: other.correction)
  }
}

extension IdentityRepair: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}

extension IdentityRepair.Correction: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
