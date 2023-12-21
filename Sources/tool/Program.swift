import ArgumentParser
import Foundation
import iTunes

extension Source: EnumerableFlag {}
extension Destination: EnumerableFlag {}

struct Program: AsyncParsableCommand {
  @Flag(help: "Input Source type") var source: Source = .itunes
  @Flag(help: "Output Destination type") var destination: Destination = .json

  @Option(
    help:
      "The path at which to create the output file. Writes to standard output if not provided.",
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

  @Option(
    help: "Repair JSON file path. Repairs well-defined and specific Tracks.",
    transform: ({ URL(filePath: $0) })
  )
  var repairFile: URL? = nil

  @Option(help: "Optional json string to parse for repairs.")
  var repairSource: String?

  @Argument(
    help:
      "Optional json string to parse when --json-string is passed as input. Use '-' as last argument to read from stdin."
  )
  var jsonSource: String?

  private var outputFile: URL? {
    guard let outputDirectory else { return nil }

    return destination.outputFile(using: outputDirectory)
  }

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
  }

  var isRepairing: Bool {
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

    let data = try tracks.data(for: destination)

    if let outputFile {
      try data.write(to: outputFile, options: .atomic)
    } else {
      print("\(try data.asUTF8String())")
    }
  }
}
