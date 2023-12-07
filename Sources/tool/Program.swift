import ArgumentParser
import Foundation
import iTunes

extension Source: EnumerableFlag {}
extension Destination: EnumerableFlag {}

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

    return destination.outputFile(using: outputDirectory)
  }

  @Flag var source: Source = .itunes
  @Flag var destination: Destination = .json

  func run() async throws {
    let tracks = try await source.gather()

    let data = try tracks.data(for: destination)

    if let outputFile {
      try data.write(to: outputFile, options: .atomic)
    } else {
      print("\(try data.asUTF8String())")
    }
  }
}
