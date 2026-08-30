import ArgumentParser
import Foundation

extension Patchable: EnumerableFlag {}

struct RepairCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "repair",
    abstract: "Repairs git repositories with itunes.json using a patch file.",
    version: iTunesVersion
  )

  /// Input source type.
  @Flag(help: "Patchable type to build.") var patchable: Patchable = .replaceDurations

  @OptionGroup var repositoryArguments: RepositoryArguments
  var repository: Repository { repositoryArguments.repository }

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

    let destinationBranch = destinationBranch ?? patchable.rawValue

    try await patch.patch(
      repository: repository,
      branch: destinationBranch,
      version: Self.configuration.version)
  }
}
