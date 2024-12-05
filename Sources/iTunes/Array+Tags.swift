//
//  Array+Tags.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import RegexBuilder

extension Array where Element == String {
  func matchingFormattedTag(prefix: String) -> [Element] {
    guard !prefix.isEmpty else { return [] }

    let regex = Regex {
      Capture {
        ZeroOrMore {
          ChoiceOf {
            OneOrMore { .word }
            "."
            "-"
          }
        }
      }
      "-"
      One(.digit)
      One(.digit)
      One(.digit)
      One(.digit)
      "-"
      One(.digit)
      One(.digit)
      "-"
      One(.digit)
      One(.digit)
      Optionally {
        "."
      }
      Optionally(.digit)
      Optionally(.digit)
    }

    return self.filter {
      if let match = try? regex.wholeMatch(in: $0) {
        String(match.output.1) == prefix
      } else {
        false
      }
    }
  }
}
