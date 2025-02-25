import ArgumentParser
import Foundation

extension Repairable: EnumerableFlag {}

private enum DestinationFlag: CaseIterable, EnumerableFlag {
  case standardOut
}

struct PatchCommand: AsyncParsableCommand {
  private static let fileName = "itunes.json"

  static let configuration = CommandConfiguration(
    commandName: "patch",
    abstract: "Creates patches for itunes.json data.",
    version: iTunesVersion
  )

  /// Input source type.
  @Flag(help: "Repairable type to build.") var repairable: Repairable = .replaceDurations

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

  @Flag(help: "Destination for the patch file.")
  fileprivate var destination: DestinationFlag = .standardOut

  /// Optional corrections to use when creating this patch.
  @Option(help: "The corrections to apply when creating this patch (as a JSON string).")
  var correction: String = ""

  private func repairDestination() throws -> RepairDestination {
    switch destination {
    case .standardOut:
      return .standardOut
    }
  }

  func run() async throws {
    let configuration = GitTagData.Configuration(
      directory: gitDirectory, fileName: PatchCommand.fileName)
    try await repairDestination().emit(try await repairable.gather(configuration, correction: correction))
  }
}
