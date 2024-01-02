//
//  SQLRow.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol SQLRow: Hashable {
  var select: String { get }
  var insert: String { get }
}
