import ArgumentParser
import Foundation
import iTunes

extension Repairable: EnumerableFlag {}

@main
struct Program: AsyncParsableCommand {
  /// Input source type.
  @Flag(help: "Repairable type to build.") var repairable: Repairable = .artists

  /// Git Directory to read and write data from.
  @Option(
    help: "The path for the git directory to work with.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      return url
    })
  )
  var gitDirectory: URL

  public func run() async throws {
    try await repairable.emit(gitDirectory)
  }
}
