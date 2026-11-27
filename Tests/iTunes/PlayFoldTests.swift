//
//  PlayFoldTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Testing

@testable import iTunes

struct PlayFoldTests {
  static let feb3 = "2025-02-03T10:05:11Z"
  static let feb20 = "2025-02-20T14:20:30Z"
  static let mar1 = "2025-03-01T10:00:00Z"
  static let mar9 = "2025-03-09T18:41:09Z"
  static let mar12 = "2025-03-12T07:33:52Z"

  static let baseline = PlayState(seenCount: 40, seenDate: mar1)

  /// Folds observations, returning the total of plays and the final state and finding codes.
  private func fold(_ start: PlayState?, _ observations: [PlayObservation]) -> (
    total: Int, state: PlayState?, codes: [PlayFindingCode]
  ) {
    var state = start
    var total = start?.seenCount ?? 0
    var codes = [PlayFindingCode]()
    for o in observations {
      let s = foldPlayObservation(state, o)
      total += s.play?.delta ?? 0
      state = s.state
      if let f = s.finding { codes.append(f.code) }
    }
    return (total, state, codes)
  }

  private func obs(_ count: Int, _ date: String?) -> PlayObservation {
    PlayObservation(count: count, date: date)
  }

  @Test func test_Case1() {
    let s = foldPlayObservation(nil, obs(12, Self.feb3))
    #expect(s.state == PlayState(seenCount: 12, seenDate: Self.feb3))
    #expect(s.play?.date == Self.feb3)
    #expect(s.play?.delta == 12)
    #expect(s.finding == nil)
  }

  @Test func test_Case2() {
    let s = foldPlayObservation(nil, obs(12, nil))
    #expect(s.state == PlayState(seenCount: 0, seenDate: ""))
    #expect(s.play == nil)
    #expect(s.finding?.code == .noPlayDate)
    #expect(s.finding?.before == nil)
    #expect(s.finding?.observation == obs(12, nil))
    #expect(s.finding?.playsAdded == 0)
    #expect(s.finding?.after == PlayState(seenCount: 0, seenDate: ""))
  }

  @Test func test_Case2EmptyString() {
    #expect(foldPlayObservation(nil, obs(12, "")).finding?.code == .noPlayDate)
  }

  @Test func test_NoStateNoCountNoDate() {
    let s = foldPlayObservation(nil, obs(0, nil))
    #expect(s.state == nil)
    #expect(s.play == nil)
    #expect(s.finding == nil)
  }

  @Test func test_ZeroCountWithDateIsOnePlay() {
    let s = foldPlayObservation(nil, obs(0, Self.feb3))
    #expect(s.state == PlayState(seenCount: 1, seenDate: Self.feb3))
    #expect(s.play?.delta == 1)
    #expect(s.finding == nil)
  }

  @Test func test_Case3() {
    for date in [nil, "", Self.mar1] {
      let s = foldPlayObservation(Self.baseline, obs(40, date))
      #expect(s.state == Self.baseline)
      #expect(s.play == nil)
      #expect(s.finding == nil)
    }
  }

  @Test func test_Case3Quirk() {
    // A whole-hour shift, as at a daylight saving change, is the same date.
    for shifted in ["2025-03-01T09:00:00Z", "2025-03-01T11:00:00Z", "2025-02-28T10:00:00Z"] {
      let s = foldPlayObservation(Self.baseline, obs(40, shifted))
      #expect(s.state == Self.baseline)
      #expect(s.state?.seenDate == Self.mar1)
      #expect(s.play == nil)
      #expect(s.finding == nil)
    }
  }

  @Test func test_Case4() {
    let s = foldPlayObservation(Self.baseline, obs(43, Self.mar9))
    #expect(s.state == PlayState(seenCount: 43, seenDate: Self.mar9))
    #expect(s.play?.date == Self.mar9)
    #expect(s.play?.delta == 3)
    #expect(s.finding == nil)
  }

  @Test func test_Case5() {
    for date in [nil, "", Self.mar1, Self.feb20] {
      let s = foldPlayObservation(Self.baseline, obs(43, date))
      #expect(s.state == Self.baseline)
      #expect(s.play == nil)
      #expect(s.finding?.code == .countUpDateNotForward)
      #expect(s.finding?.before == Self.baseline)
      #expect(s.finding?.after == Self.baseline)
    }
  }

  @Test func test_Case6() {
    let s = foldPlayObservation(Self.baseline, obs(3, Self.mar9))
    #expect(s.state == PlayState(seenCount: 3, seenDate: Self.mar9))
    #expect(s.play?.date == Self.mar9)
    #expect(s.play?.delta == 3)
    #expect(s.finding?.code == .countReset)
    #expect(s.finding?.before == Self.baseline)
    #expect(s.finding?.observation == obs(3, Self.mar9))
    #expect(s.finding?.playsAdded == 3)
    #expect(s.finding?.after == PlayState(seenCount: 3, seenDate: Self.mar9))
  }

  @Test func test_Case6ZeroCountIsOnePlay() {
    let s = foldPlayObservation(Self.baseline, obs(0, Self.mar9))
    #expect(s.state == PlayState(seenCount: 1, seenDate: Self.mar9))
    #expect(s.play?.delta == 1)
    #expect(s.finding?.code == .countReset)
  }

  @Test func test_Case7() {
    for date in [nil, Self.mar1] {
      let s = foldPlayObservation(Self.baseline, obs(3, date))
      #expect(s.state == PlayState(seenCount: 3, seenDate: Self.mar1))
      #expect(s.play == nil)
      #expect(s.finding?.code == .countDecreased)
      #expect(s.finding?.observation == obs(3, date))
      #expect(s.finding?.playsAdded == 0)
    }
  }

  @Test func test_Case7ZeroNoDate() {
    let s = foldPlayObservation(Self.baseline, obs(0, nil))
    #expect(s.state == PlayState(seenCount: 0, seenDate: Self.mar1))
    #expect(s.finding?.code == .countDecreased)
  }

  @Test func test_Case8() {
    let s = foldPlayObservation(Self.baseline, obs(40, Self.mar9))
    #expect(s.state == PlayState(seenCount: 40, seenDate: Self.mar9))
    #expect(s.play == nil)
    #expect(s.finding?.code == .dateForwardNoCount)
  }

  @Test func test_Case9() {
    let s = foldPlayObservation(Self.baseline, obs(40, Self.feb20))
    #expect(s.state == Self.baseline)
    #expect(s.play == nil)
    #expect(s.finding?.code == .dateBackward)
  }

  @Test func test_StoredDateIsVerbatim() {
    let odd = "2025-03-09T18:41:09+00:00"
    #expect(foldPlayObservation(Self.baseline, obs(41, odd)).play?.date == odd)
    #expect(foldPlayObservation(Self.baseline, obs(40, odd)).state?.seenDate == odd)
  }

  // MARK: Worked examples, with totals

  @Test func test_Example1() {
    #expect(fold(nil, [obs(12, Self.feb3)]).total == 12)
  }

  @Test func test_Example2() {
    #expect(fold(nil, [obs(12, nil)]).total == 0)
    let r = fold(nil, [obs(12, nil), obs(12, Self.feb3)])
    #expect(r.total == 12)
    #expect(r.codes == [.noPlayDate])
  }

  @Test func test_Example3() {
    #expect(fold(Self.baseline, [obs(40, Self.mar1)]).total == 40)
    #expect(fold(Self.baseline, [obs(40, nil)]).total == 40)
  }

  @Test func test_Example4() {
    #expect(fold(Self.baseline, [obs(43, Self.mar9)]).total == 43)
  }

  @Test func test_Example5() {
    #expect(fold(Self.baseline, [obs(43, nil)]).total == 40)
    let r = fold(Self.baseline, [obs(43, nil), obs(44, Self.mar12)])
    #expect(r.total == 44)
    #expect(foldPlayObservation(Self.baseline, obs(44, Self.mar12)).play?.delta == 4)
    #expect(r.codes == [.countUpDateNotForward])
  }

  @Test func test_Example6() {
    let r = fold(Self.baseline, [obs(3, Self.mar9)])
    #expect(r.total == 43)
    #expect(r.state == PlayState(seenCount: 3, seenDate: Self.mar9))
  }

  @Test func test_Example7() {
    for date in [nil, Self.mar1] {
      #expect(fold(Self.baseline, [obs(3, date)]).total == 40)
      let r = fold(Self.baseline, [obs(3, date), obs(5, Self.mar12)])
      #expect(r.total == 42)
      #expect(r.codes == [.countDecreased])
    }
  }

  @Test func test_Example8() {
    let r = fold(Self.baseline, [obs(40, Self.mar9)])
    #expect(r.total == 40)
    #expect(r.state?.seenDate == Self.mar9)
  }

  @Test func test_Example9() {
    let r = fold(Self.baseline, [obs(40, Self.feb20)])
    #expect(r.total == 40)
    #expect(r.state == Self.baseline)
  }

  // MARK: Sequences

  @Test func test_MultiStepSequence() {
    let r = fold(
      nil,
      [
        obs(0, nil),  // never played
        obs(10, Self.feb3),  // 1: 10
        obs(10, "2025-02-03T11:05:11Z"),  // 3: quirk
        obs(12, Self.feb20),  // 4: +2
        obs(14, nil),  // 5: no play
        obs(0, nil),  // 7: baseline drops to 0
        obs(1, Self.mar1),  // 4: +1
        obs(1, Self.mar9),  // 8: date moves
        obs(1, Self.feb3),  // 9: nothing
      ])
    #expect(r.total == 13)
    #expect(r.state == PlayState(seenCount: 1, seenDate: Self.mar9))
    #expect(
      r.codes == [
        .countUpDateNotForward, .countDecreased, .dateForwardNoCount, .dateBackward,
      ])
  }
}
