import ArgumentParser
import Foundation

@main
struct Program: ParsableCommand {

  @Argument(
    help:
      "The path at which to create an iTunes JSON file. Writes JSON to standard output if not provided."
  )
  var directoryPath: String = ""

  func run() throws {
    guard let tracks = try? Track.gatherAllTracks() else {
      throw ValidationError("Cannot get tracks from iTunes")
    }

    guard tracks.count > 0 else {
      throw ValidationError("No JSON to record")
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    guard let jsonData = try? encoder.encode(tracks) else {
      throw ValidationError("Unable to create JSON for \(tracks)")
    }

    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw ValidationError("Unable to create JSON string for \(tracks)")
    }

    if !directoryPath.isEmpty {
      let destinationDirectoryPath = directoryPath
      var destinationURL = URL(fileURLWithPath: destinationDirectoryPath, isDirectory: true)

      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let dateString = dateFormatter.string(from: Date())

      destinationURL.appendPathComponent("iTunes-\(dateString).json")
      FileManager.default.createFile(atPath: destinationURL.path, contents: nil, attributes: nil)

      try jsonString.write(toFile: destinationURL.path, atomically: true, encoding: .utf8)
    } else {
      print("\(jsonString)")
    }
  }
}
