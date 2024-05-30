//
//  SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

protocol SQLBindableInsert {
  static var insertBinding: Database.Statement { get }
}
