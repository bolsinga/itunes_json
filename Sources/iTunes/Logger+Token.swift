//
//  Logger+Token.swift
//
//
//  Created by Greg Bolsinga on 2/18/24.
//

import os

extension Logger {
  public init(type: String, category: String, token: String?) {
    let prefix = token != nil ? "\(token!): " : ""
    self.init(subsystem: "\(prefix)\(type)", category: category)
  }
}
