import ArgumentParser
import Foundation
import iTunes

extension Source: EnumerableFlag {}
extension Destination: EnumerableFlag {}

struct Program: AsyncParsableCommand {
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

  private var outputFile: URL? {
    guard let outputDirectory else { return nil }

    return destination.outputFile(using: outputDirectory)
  }

  @Flag(help: "Input Source type") var source: Source = .itunes
  @Flag(help: "Output Destination type") var destination: Destination = .json
  @Flag(help: "Re-Exports XML JSON file to get sorted keys") var reExport: Bool = false

  @Argument(
    help:
      "Optional json string to parse when --json-string is passed as input. Use '-' as last argument to read from stdin."
  )
  var jsonSource: String?

  mutating func validate() throws {
    if jsonSource != nil && (source != .jsonString && source != .xmlJsonString) {
      throw ValidationError("Passing JSON Source requires --json-string to be passed. \(source)")
    }

    if jsonSource == nil, source == .jsonString || source == .xmlJsonString {
      throw ValidationError("Using --json-string requires JSON String to be passed as an argument.")
    }

    if reExport && (source != .xmlJsonString || destination != .json || outputFile != nil) {
      throw ValidationError("reExport is only for xml json strings output to json via stdout.")
    }
  }

  func run() async throws {
    if reExport {
      try source.reExport(jsonSource)
      return
    }
    let tracks = try await source.gather(jsonSource)

    let data = try tracks.data(for: destination)

    if let outputFile {
      try data.write(to: outputFile, options: .atomic)
    } else {
      print("\(try data.asUTF8String())")
    }
  }
}
