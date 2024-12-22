//
//  PackageBuildInfo+Version.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/21/24.
//

import Foundation

extension PackageBuild {
  var name: String {
    guard let name = tag else {
      guard let name = branch else {
        return commit
      }
      return name
    }
    return name
  }

  var modifiedName: String {
    isDirty ? "\(name)-\(countSinceTag)-local" : "\(name)-\(countSinceTag)"
  }

  var version: String {
    (countSinceTag > 0) ? modifiedName : name
  }
}

public let iTunesVersion = PackageBuild.info.version
