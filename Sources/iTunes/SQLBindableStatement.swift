//
//  SQLBindableStatement.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

protocol SQLBindableStatement {}

protocol SQLBindableInsert: SQLBindableStatement {
  static var insertBinding: Database.Statement { get }
}
