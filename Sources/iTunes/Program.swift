import ArgumentParser
import Foundation

extension Source: EnumerableFlag {}
extension Destination: EnumerableFlag {}
extension SchemaConstraints: EnumerableFlag {}

public struct Program: AsyncParsableCommand {
  /// Input source type.
  @Flag(help: "Input Source type. Where Track data is being read from.") var source: Source =
    .itunes
  /// Output destination type.
  @Flag(help: "Output Destination type. Format Track data will be written out as.") var destination:
    Destination = .json
  /// Should Tracks be reduced
  @Flag(
    help:
      "Reduce Tracks to minimum required fields and music related only. Defaults to false, unless repairing."
  ) var reduce: Bool = false

  /// Database schema constraints. Only applicable with --sql-code or --db.
  @Flag(help: "Database schema constraints. Only applicable with --sql-code or --db.")
  var schemaConstraints: SchemaConstraints = .strict

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

  /// Optional repair file path.
  @Option(
    help: "Repair JSON file path. Repairs well-defined and specific Tracks.",
    transform: ({ URL(filePath: $0) })
  )
  var repairFile: URL? = nil

  /// Optional repair json source string.
  @Option(help: "Optional json string to parse for repairs.")
  var repairSource: String?

  /// JSON Source to parse when using Source.jsonString.
  @Argument(
    help:
      "Optional json string to parse when --json-string is passed as input. Use '-' as last argument to read from stdin."
  )
  var jsonSource: String?

  /// Optional file name to use. Default is 'iTunes-yyyy-MM-dd". Its extension is always based upon the --destination.
  @Option(
    help:
      "Optional file name to use when outputDirectory is used. If not set, the file name will be based upon the current date."
  )
  var fileName: String?

  @Option(help: "Optional string to add to debug logs for debugging.")
  var loggingToken: String?

  @Option(help: "Optional filter for an Artist Name.")
  var artistNameFilter: String?

  /// Outputfile where data will be writen, if outputDirectory is not specified.
  private var outputFile: URL? {
    guard let outputDirectory else { return nil }

    return destination.outputFile(using: outputDirectory, name: fileName)
  }

  /// Validates the input matrix.
  public mutating func validate() throws {
    if jsonSource != nil && source != .jsonString {
      throw ValidationError("Passing JSON Source requires --json-string to be passed. \(source)")
    }

    if jsonSource == nil, source == .jsonString {
      throw ValidationError("Using --json-string requires JSON String to be passed as an argument.")
    }

    if (repairFile != nil) && (repairSource != nil) {
      throw ValidationError("repairSource is already defined, but repairFile is being passed.")
    }

    if destination == .db && outputFile == nil {
      throw ValidationError("--db requires outputDirectory to be set")
    }

    if destination == .jsonGit && outputFile == nil {
      throw ValidationError("--json-git requires outputDirectory to be set")
    }
  }

  /// Indicates if the Track data is going to be repaired.
  private var isRepairing: Bool {
    repairFile != nil || (repairSource != nil && !repairSource!.isEmpty)
  }

  private func repairing() async throws -> Repairing? {
    guard isRepairing else { return nil }
    return try await createRepair(url: repairFile, source: repairSource, loggingToken: loggingToken)
  }

  private var isReducing: Bool {
    isRepairing || reduce
  }

  public func run() async throws {
    let tracks = try await {
      let artistIncluded: ((String) -> Bool)? = {
        if let artistNameFilter, !artistNameFilter.isEmpty {
          return { $0 == artistNameFilter }
        }
        return nil
      }()
      return try await source.gather(
        jsonSource, repair: try await repairing(), artistIncluded: artistIncluded,
        reduce: isReducing)
    }()

    try await destination.emit(
      tracks, outputFile: outputFile, loggingToken: loggingToken, branch: "main", tagPrefix: "iTunes", schemaConstraints: schemaConstraints)
  }

  private static func readSTDIN() -> String? {
    var input: String = ""

    while let line = readLine() {
      if input.isEmpty {
        input = line
      } else {
        input += "\n" + line
      }
    }

    return input
  }

  static public func parseStandardInAndArgumentsOrExit(arguments: [String]) async {
    var text: String?
    var arguments = arguments

    if arguments.last == "-" {
      arguments.removeLast()

      text = Self.readSTDIN()
    }

    arguments.removeFirst()
    if let text = text {
      arguments.insert(text, at: 0)
    }

    let command = Self.parseOrExit(arguments)
    do {
      try await command.run()
    } catch {
      Self.exit(withError: error)
    }
  }

  public init() {}  // This is public and empty to help the compiler.
}
