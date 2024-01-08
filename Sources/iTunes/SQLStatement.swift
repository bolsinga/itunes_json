//
//  SQLStatement.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol SQLStatement {}

protocol SQLSelectID: SQLStatement {
  var selectID: String { get }
}
