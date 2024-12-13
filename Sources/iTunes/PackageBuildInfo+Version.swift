//
//  PackageBuildInfo+Version.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/21/24.
//

import Foundation

extension PackageBuild {
  public var version : String {
    guard let name = tag else {
      guard let name = branch else {
        return commit
      }
      return name
    }
    return name
  }
}

public let iTunesVersion = PackageBuild.info.version
