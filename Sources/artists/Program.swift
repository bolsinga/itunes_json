import ArgumentParser
import Foundation
import iTunes

@main
struct Program: AsyncParsableCommand {
  /// Input source type.
  @Flag(help: "Input Source type. Where Track data is being read from.") var source: Source =
    .itunes
  /// Output destination type.
  @Flag(help: "Output Destination type. Format Artist data will be written out as.")
  var destination: Destination = .json

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

    if destination == .db && outputFile == nil {
      throw ValidationError("--db requires outputDirectory to be set")
    }

    if destination == .jsonGit {
      throw ValidationError("--json-git is invalid for Artists.")
    }
  }

  public func run() async throws {
    let tracks = try await source.gather(
      jsonSource, repair: nil, artistIncluded: nil, reduce: false)
    try await destination.emitSortableNames(
      for: tracks, outputFile: outputFile, descriptiveName: "artists")
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
}
