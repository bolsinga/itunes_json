import ArgumentParser
import Foundation
import iTunes

extension Source: EnumerableFlag {}
extension Destination: EnumerableFlag {}

struct Program: AsyncParsableCommand {
  /// Input source type.
  @Flag(help: "Input Source type. Where Track data is being read from.") var source: Source =
    .itunes
  /// Output destination type.
  @Flag(help: "Output Destination type. Format Track data will be written out as.") var destination:
    Destination = .json

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

  @Flag
  var timeTest = false

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
  mutating func validate() throws {
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
  }

  /// Indicates if the Track data is going to be repaired.
  private var isRepairing: Bool {
    repairFile != nil || (repairSource != nil && !repairSource!.isEmpty)
  }

  func run() async throws {
    LoggingToken = loggingToken

    guard !timeTest else {
      let result = await testTime()
      if result != 0 { throw ExitCode(Int32(result)) }
      return
    }

    let tracks = try await {
      let repair =
        isRepairing ? try? await createRepair(url: repairFile, source: repairSource) : nil
      let artistIncluded: ((String) -> Bool)? = {
        if let artistNameFilter, !artistNameFilter.isEmpty {
          return { $0 == artistNameFilter }
        }
        return nil
      }()
      return try await source.gather(jsonSource, repair: repair, artistIncluded: artistIncluded)
    }()

    try await destination.emit(tracks, outputFile: outputFile)
  }
}
