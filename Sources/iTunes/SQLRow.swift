//
//  SQLRow.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol SQLRow: Hashable {
  var insertStatement: String { get }
}
