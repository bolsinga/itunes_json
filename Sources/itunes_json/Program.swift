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
    if !directoryPath.isEmpty {
      try Track.export(directoryPath)
    } else {
      print("\(try Track.jsonString())")
    }
  }
}
