import ArgumentParser
import Foundation
import iTunes

let fileName = "itunes.json"

extension Repairable: EnumerableFlag {}

@main
struct PatchMusic: AsyncParsableCommand {
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

  @Option(help: "The prefix to use for the git tags.") var sourceTagPrefix: String = "iTunes"

  public func run() async throws {
    let configuration = GitTagDataSequence.Configuration(
      directory: gitDirectory, tagPrefix: sourceTagPrefix, fileName: fileName)
    print(try await repairable.gather(configuration))
  }
}
