//
//  TagParser.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import RegexBuilder

struct TagParser {
  private let tagVersionRegex = Regex {
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

  private let tagPrefixAndStampRegex = Regex {
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

  internal func tagVersion(_ string: String) -> (String, Int)? {
    if let match = try? tagVersionRegex.wholeMatch(in: string) {
      return (String(match.output.1), match.output.2)
    }
    return nil
  }

  internal func tagPrefixAndStamp(_ string: String) -> (String, String)? {
    if let match = try? tagPrefixAndStampRegex.wholeMatch(in: string) {
      return (String(match.output.1), String(match.output.2))
    }
    return nil
  }

  public func structuredTag(_ string: String) -> StructuredTag? {
    guard let (prefix, stamp) = tagPrefixAndStamp(string) else { return nil }
    guard let (root, version) = tagVersion(prefix) else { return nil }
    return StructuredTag(root: root, version: version, stamp: stamp)
  }

  public func tagPrefix(_ string: String) -> String? {
    tagPrefixAndStamp(string)?.0
  }
}
