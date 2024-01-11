//
//  Destination+URL.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Destination {
  fileprivate var defaultName: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())
    return "iTunes-\(dateString)"
  }

  public func outputFile(using directory: URL, name: String? = nil) -> URL? {
    let name = name ?? defaultName
    return directory.appending(path: "\(name).\(self.filenameExtension)")
  }
}
