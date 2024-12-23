import ArgumentParser
import Foundation

public struct TunesCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "tunes",
    abstract: "A tool for working with iTunes data.",
    version: iTunesVersion,
    subcommands: [BackupCommand.self, PatchCommand.self, RepairCommand.self, BatchCommand.self],
    defaultSubcommand: BackupCommand.self
  )

  public init() {}  // This is public and empty to help the compiler.

  public static func go(_ arguments: [String]?) async {
    await Self.main(arguments)
  }
}
