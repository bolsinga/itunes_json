//
//  String+Tags.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import RegexBuilder

extension String {
  func matchingFormattedTag(prefix: String) -> Bool {
    guard !prefix.isEmpty else { return false }

    let regex = Regex {
      Capture {
        OneOrMore {
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

    if let match = try? regex.wholeMatch(in: self) {
      return String(match.output.1) == prefix
    } else {
      return false
    }
  }
}
