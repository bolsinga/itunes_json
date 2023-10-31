import ArgumentParser
import Foundation
import iTunes

extension Source: EnumerableFlag {}

@main
struct Program: AsyncParsableCommand {

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

  @Flag var source: Source = .itunes

  func run() async throws {
    if let outputFile {
      try await Track.export(to: outputFile, source: source)
    } else {
      print("\(try await Track.jsonString(source))")
    }
  }
}
