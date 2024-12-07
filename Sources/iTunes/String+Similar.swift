//
//  String+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/24/24.
//

import Foundation
import RegexBuilder

extension String {
  private var removeCommonInitialWords: String {
    let regex = Regex {
      Optionally {
        ChoiceOf {
          "The"
          "A"
          "An"
        }
        OneOrMore {
          .whitespace
        }
      }
    }.ignoresCase()

    return String(self.trimmingPrefix(regex))
  }

  internal var trimmedForSimilarity: String {
    var interim = self.removeCommonInitialWords.trimmingCharacters(
      in: .whitespacesAndNewlines)
    interim.unicodeScalars.removeAll(where: { CharacterSet.alphanumerics.inverted.contains($0) })
    return interim
  }

  func isSimilar(to other: String) -> Bool {
    var options = String.CompareOptions()
    options.insert(.caseInsensitive)
    options.insert(.diacriticInsensitive)

    return self.trimmedForSimilarity.compare(other.trimmedForSimilarity, options: options)
      == ComparisonResult.orderedSame
  }
}
