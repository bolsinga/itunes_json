import ArgumentParser
import Foundation
import iTunes

@main
struct Program: ParsableCommand {

  @Argument(
    help:
      "The path at which to create an iTunes JSON file. Writes JSON to standard output if not provided.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let dateString = dateFormatter.string(from: Date())

      return url.appending(path: "iTunes-\(dateString).json")
    })
  )
  var outputFile: URL? = nil

  func run() throws {
    if let outputFile {
      try Track.export(to: outputFile)
    } else {
      print("\(try Track.jsonString())")
    }
  }
}
