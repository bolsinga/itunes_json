//
//  Destination+URL.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Destination {
  public func outputFile(using directory: URL) -> URL? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())

    return directory.appending(path: "iTunes-\(dateString).\(self.filenameExtension)")
  }
}
