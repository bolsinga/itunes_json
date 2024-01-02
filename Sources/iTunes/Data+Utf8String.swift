//
//  Data+Utf8String.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

enum DataUTF8Error: Error {
  case cannotConvertToUTF8String
}

extension Data {
  func asUTF8String() throws -> String {
    guard let s = String(data: self, encoding: .utf8) else {
      throw DataUTF8Error.cannotConvertToUTF8String
    }
    return s
  }
}
