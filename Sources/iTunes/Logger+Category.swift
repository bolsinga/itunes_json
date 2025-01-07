//
//  Logger+Category.swift
//
//
//  Created by Greg Bolsinga on 7/2/23.
//

import Foundation
import os

extension Logger {
  public init(category: String) {
    self.init(subsystem: Bundle.module.bundleIdentifier ?? "unknown", category: category)
  }
}
