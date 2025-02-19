//
//  PlayTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/16/25.
//

import Foundation
import Testing

@testable import iTunes

extension Play {
  fileprivate func advanced(by interval: TimeInterval) -> Play {
    Play(date: date?.advanced(by: interval), count: count)
  }

  fileprivate func incremented(by difference: Int) -> Play {
    Play(date: date, count: (count ?? 0) + difference)
  }
}

struct PlayTests {
  var date: Date { try! Date.ISO8601FormatStyle().parse("2005-12-22T23:06:50Z") }
  let count = 5

  var valid: Play { Play(date: self.date, count: count) }
  var invalid: Play { Play(date: nil, count: nil) }

  @Test func singleValid() async throws {
    #expect([valid].normalize() == [valid])
  }

  @Test func singleInvalid() async throws {
    #expect([invalid].normalize() == [])
  }

  @Test func invalidInitial() async throws {
    #expect([invalid, valid].normalize() == [])
  }

  @Test func invalidOther() async throws {
    #expect([valid, invalid].normalize() == [valid])
  }

  @Test func valid() async throws {
    let other = valid.advanced(by: 60).incremented(by: 1)
    #expect([valid, other].normalize() == [valid, other])
  }

  @Test func reverse() async throws {
    let other = valid.advanced(by: -60).incremented(by: -1)
    #expect([valid, other].normalize() == [valid])
  }

  @Test func same() async throws {
    #expect([valid, valid].normalize() == [valid, valid])
  }

  @Test func advanceOneHourExactly() async throws {
    let other = valid.advanced(by: 60 * 60)
    #expect([valid, other].normalize() == [valid, valid])
  }

  @Test func reverseOneHourExactly() async throws {
    let other = valid.advanced(by: -60 * 60)
    #expect([valid, other].normalize() == [valid, valid])
  }

  @Test func reverseDateOnly() async throws {
    let other = valid.advanced(by: -60)
    #expect([valid, other].normalize() == [valid])
  }

  @Test func reverseDateAdvanceCount() async throws {
    let other = valid.advanced(by: -60).incremented(by: 1)
    #expect([valid, other].normalize() == [valid])
  }

  @Test func advanceDateOnly() async throws {
    let other = valid.advanced(by: 60)
    #expect([valid, other].normalize() == [valid])
  }

  @Test func advanceDateReverseCount() async throws {
    let other = valid.advanced(by: 60).incremented(by: -1)
    #expect([valid, other].normalize() == [valid])
  }

  @Test func advanceDateCountZero() async throws {
    let other = valid.advanced(by: 60).incremented(by: -(valid.count ?? 0))
    #expect([valid, other].normalize() == [valid, valid.advanced(by: 60).incremented(by: 1)])
  }

  @Test func advanceDateCountNil() async throws {
    let other = Play(date: date.advanced(by: 60), count: nil)
    #expect([valid, other].normalize() == [valid, valid.advanced(by: 60).incremented(by: 1)])
  }

  @Test func sameDateCountZero() async throws {
    let other = valid.incremented(by: -(valid.count ?? 0))
    #expect([valid, other].normalize() == [valid])
  }
}
