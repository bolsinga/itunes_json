import ArgumentParser
import Foundation

extension Patchable: EnumerableFlag {}

struct RepairCommand: AsyncParsableCommand {
  private static let fileName = "itunes.json"

  static let configuration = CommandConfiguration(
    commandName: "repair",
    abstract: "Repairs git repositories with itunes.json using a patch file.",
    version: iTunesVersion
  )

  /// Input source type.
  @Flag(help: "Patchable type to build.") var patchable: Patchable = .replaceDurations

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

  /// Patch File URL.
  @Option(
    help: "Patch JSON file path.",
    transform: ({ URL(filePath: $0) })
  )
  var patchURL: URL

  @Option(help: "The destination git branch. Defaults to the patchable type name.")
  var destinationBranch: String?

  func run() async throws {
    let patch = try await patchable.createPatch(patchURL)

    let sourceConfiguration = GitTagData.Configuration(
      directory: gitDirectory, fileName: Self.fileName)

    let destinationBranch = destinationBranch ?? patchable.rawValue

    let destinationConfiguration = GitTagData.Configuration(
      directory: gitDirectory, branch: destinationBranch, fileName: Self.fileName)

    try await patch.patch(
      sourceConfiguration: sourceConfiguration, patch: patch,
      destinationConfiguration: destinationConfiguration, version: Self.configuration.version)
  }
}
