//
//  String+DefaultName.swift
//
//
//  Created by Greg Bolsinga on 3/21/24.
//

import Foundation

extension String {
  var defaultDestinationName: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())
    return "\(self)-\(dateString)"
  }
}
