//
//  String+Tags.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import RegexBuilder

extension String {
  var structuredTag: StructuredTag? {
    guard let (prefix, stamp) = tagPrefixAndStamp else { return nil }
    guard let (root, version) = prefix.tagVersion else { return nil }
    return StructuredTag(root: root, version: version, stamp: stamp)
  }

  var tagVersion: (String, Int)? {
    let regex = Regex {
      Capture { OneOrMore { .word } }
      ChoiceOf {
        "-"
        "."
      }
      OneOrMore { .word }
      TryCapture {
        OneOrMore { .digit }
      } transform: {
        Int($0)
      }
    }
    .repetitionBehavior(.reluctant)

    if let match = try? regex.wholeMatch(in: self) {
      return (String(match.output.1), match.output.2)
    }
    return nil
  }

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
}
