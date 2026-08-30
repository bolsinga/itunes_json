//
//  BackupCommand.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/13/24.
//
import ArgumentParser
import Foundation

/// The destination type for the Track data.
enum DestinationContext: EnumerableFlag {
  /// Emit a JSON string representing the Tracks.
  case json
  /// Emit JSON representing the Tracks and add to a git repository
  case jsonGit
  /// Emit Normalized SQLite code that represents the Tracks.
  case sqlCode
  /// Emit a Normalized sqlite3 database that represents the Tracks.
  case db
  /// Emit a Flat sqlite3 database that represents the Tracks.
  case flat

  fileprivate func outputFile(using directory: URL, name: String?) -> URL? {
    let name = name ?? "iTunes".defaultDestinationName
    return directory.appending(path: "\(name).\(filenameExtension)")
  }

  fileprivate var filenameExtension: String {
    switch self {
    case .json, .jsonGit:
      "json"
    case .sqlCode:
      "sql"
    case .db, .flat:
      "db"
    }
  }
}

extension SchemaConstraints: EnumerableFlag {}
extension Source: EnumerableFlag {}

struct BackupCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "backup",
    abstract: "Backs up music data.",
    version: iTunesVersion
  )

  /// Input source type.
  @Flag(help: "Input Source type. Where Track data is being read from.") var source: Source =
    .itunes

  /// Output destination type.
  @Flag(help: "Output Destination type. Format Track data will be written out as.") var destination:
    DestinationContext = .json
  /// Should Tracks be reduced
  @Flag(
    help:
      "Reduce Tracks to minimum required fields and music related only. Defaults to false."
  ) var reduce: Bool = false

  /// Lax normalized database schema table constraints. Only applicable with --sql-code or --db.
  @Flag(
    help:
      "Lax normalized database schema table constraints. Only applicable with --sql-code or --db."
  )
  var laxSchema: [SchemaFlag] = []

  /// Optional Output Directory for output file.
  @Option(
    help:
      "The path at which to create the output file. If possible, writes to standard output if not provided.",
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

  /// Optional file name to use. Default is 'iTunes-yyyy-MM-dd". Its extension is always based upon the --destination.
  @Option(
    help:
      "Optional file name to use when outputDirectory is used. If not set, the file name will be based upon the current date."
  )
  var fileName: String?

  /// Patch File URL.
  @Option(
    help: "Patch JSON file path.",
    transform: ({ URL(filePath: $0) })
  )
  var patchURL: URL?

  /// Output-file where data will be written, if outputDirectory is not specified.
  private var outputFile: URL? {
    guard let outputDirectory else { return nil }

    return destination.outputFile(using: outputDirectory, name: fileName)
  }

  /// Validates the input matrix.
  func validate() throws {
    switch destination {
    case .db, .flat:
      if outputFile == nil {
        throw ValidationError("\(destination) requires an outputFile to be set")
      }
    case .jsonGit:
      if outputDirectory == nil {
        throw ValidationError("\(destination) requires an outputDirectory to be set")
      }
    default:
      break
    }
  }

  private func tracks() async throws -> [Track] {
    var tracks = try await source.gather(reduce: reduce)
    if let patchURL {
      tracks = try await tracks.backupPatch(patchURL)
    }
    return tracks
  }

  private var output: Output {
    guard let outputFile else { return .standardOut }
    return .file(outputFile)
  }

  private var context: Destination {
    switch destination {
    case .json:
      return .json(output)
    case .jsonGit:
      guard let outputDirectory else {
        preconditionFailure(".jsonGit requires an output directory. failed validation")
      }
      return .jsonGit(
        GitBackupContext(
          repository: Repository(directory: outputDirectory), version: Self.configuration.version))
    case .sqlCode:
      return .sqlCode(
        SQLCodeContext(output: output, schemaOptions: laxSchema.schemaOptions, loggingToken: nil))
    case .db:
      guard let outputFile else {
        preconditionFailure(".db requires an output file. failed validation")
      }
      return .db(
        .normalized(
          DatabaseContext(storage: .file(outputFile), schemaOptions: laxSchema.schemaOptions)))
    case .flat:
      guard let outputFile else { fatalError(".flat requires an output file. failed validation") }
      return .db(.flat(FlatTracksDatabaseContext(storage: .file(outputFile))))
    }
  }

  func run() async throws {
    try await context.emit(tracks())
  }
}
