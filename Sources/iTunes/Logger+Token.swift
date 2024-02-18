//
//  Logger+Token.swift
//
//
//  Created by Greg Bolsinga on 2/18/24.
//

import os

extension Logger {
  public init(type: String, category: String) {
    let prefix = LoggingToken != nil ? "\(LoggingToken!): " : ""
    self.init(subsystem: "\(prefix)\(type)", category: category)
  }
}
