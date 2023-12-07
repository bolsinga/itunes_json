import ArgumentParser
import Foundation
import iTunes

extension Source: EnumerableFlag {}

@main
struct Program: AsyncParsableCommand {

  @Argument(
    help:
      "The path at which to create the output file. Writes to standard output if not provided.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      return url
    })
  )
  var outputDirectory: URL? = nil

  private var outputFile: URL? {
    guard let outputDirectory else { return nil }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())

    return outputDirectory.appending(path: "iTunes-\(dateString).json")
  }

  @Flag var source: Source = .itunes

  func run() async throws {
    let tracks = try await source.gather()
    if let outputFile {
      try Track.export(to: outputFile, tracks: tracks)
    } else {
      print("\(try Track.jsonString(tracks))")
    }
  }
}
