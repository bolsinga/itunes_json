import ArgumentParser
import Foundation

extension Repairable: EnumerableFlag {}

private enum DestinationFlag: CaseIterable, EnumerableFlag {
  case standardOut
  case database
}

struct PatchCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "patch",
    abstract: "Creates patches for itunes.json data.",
    version: iTunesVersion
  )

  /// Input source type.
  @Flag(help: "Repairable type to build.") var repairable: Repairable = .replaceDurations

  @OptionGroup var repositoryArguments: RepositoryArguments
  var repository: Repository { repositoryArguments.repository }

  /// Database File URL.
  @Option(help: "Database file path.", transform: ({ URL(filePath: $0) })) var databaseURL: URL?

  @Flag(help: "Destination for the patch file.")
  fileprivate var destination: DestinationFlag = .standardOut

  /// Optional corrections to use when creating this patch.
  @Option(help: "The corrections to apply when creating this patch (as a JSON string).")
  var correction: String = ""

  private func repairDestination() throws -> RepairDestination {
    enum DestinationError: Error {
      case noDBOutputFile
    }
    switch destination {
    case .standardOut:
      return .standardOut
    case .database:
      guard let databaseURL else { throw DestinationError.noDBOutputFile }
      return .database(databaseURL)
    }
  }

  func validate() throws {
    if destination == .database && databaseURL == nil {
      throw ValidationError("--database requires databaseURL to be set")
    }
  }

  func run() async throws {
    try await repairDestination().emit(
      try await repairable.gather(repository: repository, correction: correction))
  }
}
