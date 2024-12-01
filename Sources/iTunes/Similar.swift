//
//  Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

protocol Similar: Sendable {
  func isSimilar(to other: Self) -> Bool
  var cullable: Bool { get }
}
