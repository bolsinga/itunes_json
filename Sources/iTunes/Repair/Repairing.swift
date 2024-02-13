//
//  Repairing.swift
//
//
//  Created by Greg Bolsinga on 2/12/24.
//

import Foundation

public protocol Repairing {
  func repair(_ tracks: [Track]) -> [Track]
}
