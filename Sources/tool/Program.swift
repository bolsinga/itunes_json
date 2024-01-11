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
      "The path at which to create the output file. The file name will be based upon the date and the --destination. If possible, writes to standard output if not provided.",
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

  /// Outputfile where data will be writen, if outputDirectory is not specified.
  private var outputFile: URL? {
    guard let outputDirectory else { return nil }

    return destination.outputFile(using: outputDirectory)
  }

  /// Validates the input matrix.
  mutating func validate() throws {
    if jsonSource != nil && source != .jsonString {
      throw ValidationError("Passing JSON Source requires --json-string to be passed. \(source)")
    }

    if jsonSource == nil, source == .jsonString {
      throw ValidationError("Using --json-string requires JSON String to be passed as an argument.")
    }

    if isRepairing && (source != .jsonString || destination != .json) {
      throw ValidationError(
        "Repairing requires source json (actually \(source)) to be converted to destination json (actually \(destination))."
      )
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
    let tracks = try await {
      let t = try await source.gather(jsonSource)
      if isRepairing {
        let repair = try await Repair.create(url: repairFile, source: repairSource)
        return repair.repair(t)
      }
      return t
    }()

    try await destination.emit(tracks, outputFile: outputFile)
  }
}
