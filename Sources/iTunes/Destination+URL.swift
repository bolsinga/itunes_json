//
//  Destination+URL.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Destination {
  public func outputFile(using directory: URL, name: String?) -> URL? {
    let name = name ?? String.defaultDestinationName
    return directory.appending(path: "\(name).\(self.filenameExtension)")
  }
}
