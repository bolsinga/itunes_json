import ArgumentParser
import Foundation

extension Patchable: EnumerableFlag {}

extension Dictionary where Key: Codable & Comparable, Value: Codable & Comparable, Key == Value {
  static fileprivate func load(from url: URL) throws -> Self {
    try load(from: try Data(contentsOf: url, options: .mappedIfSafe))
  }

  static fileprivate func load(from data: Data) throws -> Self {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(Self.self, from: data)
  }
}

extension AlbumMissingTitlePatchLookup {
  static fileprivate func load(from url: URL) throws -> Self {
    try load(from: try Data(contentsOf: url, options: .mappedIfSafe))
  }

  static fileprivate func load(from data: Data) throws -> Self {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(Self.self, from: data)
  }
}

extension Patchable {
  fileprivate func createPatch(_ fileURL: URL) throws -> Patch {
    switch self {
    case .artists:
      Patch.artists(try ArtistPatchLookup.load(from: fileURL))
    case .albums:
      Patch.albums(try AlbumPatchLookup.load(from: fileURL))
    case .missingTitleAlbums:
      Patch.missingTitleAlbums(try AlbumMissingTitlePatchLookup.load(from: fileURL))
    }
  }
}

public struct RepairCommand: AsyncParsableCommand {
  private static let fileName = "itunes.json"

  public static let configuration = CommandConfiguration(
    commandName: "repair",
    abstract: "Repairs git repositories with itunes.json using a patch file.",
    version: iTunesVersion
  )

  /// Input source type.
  @Flag(help: "Patchable type to build.") var patchable: Patchable = .artists

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

  @Option(help: "The prefix to use for the source git tags.") var sourceTagPrefix: String = "iTunes"

  @Option(
    help:
      "The string to append to the sourceTagPrefix for the destination git branch."
  )
  var destinationTagPrefix: String

  @Option(help: "The destination git branch. Defaults to the patchable type name.")
  var destinationBranch: String?

  public func run() async throws {
    let patch = try patchable.createPatch(patchURL)

    let sourceConfiguration = GitTagData.Configuration(
      directory: gitDirectory, tagPrefix: sourceTagPrefix, fileName: Self.fileName)

    let destinationBranch = destinationBranch ?? patchable.rawValue

    let destinationConfiguration = GitTagData.Configuration(
      directory: gitDirectory, branch: destinationBranch, fileName: Self.fileName)

    try await patch.patch(
      sourceConfiguration: sourceConfiguration,
      patch: patch,
      destinationTagPrefix: destinationTagPrefix,
      destinationConfiguration: destinationConfiguration, version: Self.configuration.version)
  }

  public init() {}  // This is public and empty to help the compiler.
}
