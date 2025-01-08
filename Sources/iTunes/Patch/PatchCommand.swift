import ArgumentParser
import Foundation

extension Repairable: EnumerableFlag {}

struct PatchCommand: AsyncParsableCommand {
  private static let fileName = "itunes.json"

  static let configuration = CommandConfiguration(
    commandName: "patch",
    abstract: "Creates patches for itunes.json data.",
    version: iTunesVersion
  )

  /// Input source type.
  @Flag(help: "Repairable type to build.") var repairable: Repairable = .artists

  @Flag(help: "How to filter git tags. Default is .ordered")
  var tagFilter: TagFilter = .ordered

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

  /// Optional corrections to use when creating this patch.
  @Option(help: "The corrections to apply when creating this patch (as a JSON string).")
  var correction: String = ""

  func run() async throws {
    let configuration = GitTagData.Configuration(
      directory: gitDirectory, tagPrefix: sourceTagPrefix, fileName: PatchCommand.fileName,
      tagFilter: tagFilter)
    print(try await repairable.gather(configuration, correction: correction))
  }
}
