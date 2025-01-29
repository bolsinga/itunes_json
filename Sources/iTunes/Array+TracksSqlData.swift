//
//  Array+TracksSqlData.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Array where Element == Track {
  func sqlData(_ context: SQLCodeContext) throws -> Data {
    try TracksSQLSourceEncoder(context: context).encode(self)
  }
}
