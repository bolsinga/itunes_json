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
  /// Emit SQLite code that represents the Tracks.
  case sqlCode
  /// Emit a sqlite3 database that represents the Tracks.
  case db

  func context(outputFile: URL?, schemaOptions: SchemaOptions) throws -> Destination {
    enum DestinationError: Error {
      case noDBOutputFile
      case invalidUpdateDB
    }

    let output: Output = {
      guard let outputFile else { return .standardOut }
      return .file(outputFile)
    }()

    switch self {
    case .json:
      return .json(output)
    case .jsonGit:
      return .jsonGit(output)
    case .sqlCode:
      return .sqlCode(
        SQLCodeContext(output: output, schemaOptions: schemaOptions, loggingToken: nil))
    case .db:
      switch output {
      case .file(let outputFile):
        return .db(DatabaseContext(storage: .file(outputFile)))
      case .standardOut, .update:
        throw DestinationError.noDBOutputFile
      }
    }
  }

  func outputFile(using directory: URL, name: String?) -> URL? {
    let name = name ?? "iTunes".defaultDestinationName
    return directory.appending(path: "\(name).\(self.filenameExtension)")
  }

  var filenameExtension: String {
    switch self {
    case .json, .jsonGit:
      "json"
    case .sqlCode:
      "sql"
    case .db:
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

  /// Lax database schema table constraints. Only applicable with --sql-code or --db.
  @Flag(
    help:
      "Lax database schema table constraints. Only applicable with --sql-code or --db."
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

  @Option(
    help: "The prefix to use for the git tags. If not set, will try to find most recent tag prefix."
  ) var tagPrefix: String?

  /// Outputfile where data will be writen, if outputDirectory is not specified.
  private var outputFile: URL? {
    guard let outputDirectory else { return nil }

    return destination.outputFile(using: outputDirectory, name: fileName)
  }

  private var context: BackupContext {
    BackupContext(branch: "main", tagPrefix: tagPrefix, version: Self.configuration.version)
  }

  /// Validates the input matrix.
  func validate() throws {
    if destination == .db && outputFile == nil {
      throw ValidationError("--db requires outputDirectory to be set")
    }

    if destination == .jsonGit && outputFile == nil {
      throw ValidationError("--json-git requires outputDirectory to be set")
    }
  }

  func run() async throws {
    let tracks = try await source.gather(reduce: reduce)
    let schemaOptions = laxSchema.schemaOptions
    try await destination.context(outputFile: outputFile, schemaOptions: schemaOptions).emit(
      tracks, context: context, schemaOptions: schemaOptions)
  }
}
