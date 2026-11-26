//
//  TransformErrorTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/25/26.
//

import Testing

@testable import iTunes

struct TransformErrorTests {
  struct Boom: Error, CustomStringConvertible {
    var description: String { "boom" }
  }

  @Test func describesEveryFailureWhenThereAreFew() {
    let error = TransformError(failures: [
      TransformError.Failure(tag: "a", error: Boom()),
      TransformError.Failure(tag: "b", error: Boom()),
    ])
    #expect(error.description == "The transform failed for 2 tag(s).\na: boom\nb: boom")
  }

  @Test func summarizesTheRestWhenThereAreMany() {
    let failures = (0..<12).map { TransformError.Failure(tag: "t\($0)", error: Boom()) }
    let lines = TransformError(failures: failures).description.split(separator: "\n")

    // The count, the first ten failures, and a line for the other two.
    #expect(lines.count == 12)
    #expect(lines.first == "The transform failed for 12 tag(s).")
    #expect(lines[10] == "t9: boom")
    #expect(lines.last == "... and 2 more")
  }
}
