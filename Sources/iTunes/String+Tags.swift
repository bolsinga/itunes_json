//
//  String+Tags.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import RegexBuilder

extension String {
  var tagPrefixAndStamp: (String, String)? {
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
      Capture {
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
    }
    .repetitionBehavior(.reluctant)

    if let match = try? regex.wholeMatch(in: self) {
      return (String(match.output.1), String(match.output.2))
    }
    return nil
  }

  var tagPrefix: String? {
    tagPrefixAndStamp?.0
  }

  func matchingFormattedTag(prefix: String) -> Bool {
    guard !prefix.isEmpty else { return false }

    guard let existingPrefix = tagPrefix else { return false }

    return existingPrefix == prefix
  }

  func replacePrefix(newPrefix: String) -> String? {
    guard let prefix = tagPrefix else { return nil }

    return self.replacing(prefix, with: newPrefix)
  }

  func appendToPrefix(appendix: String) -> String? {
    guard let prefix = tagPrefix else { return nil }

    return self.replacing(prefix, with: "\(prefix).\(appendix)")
  }
}
