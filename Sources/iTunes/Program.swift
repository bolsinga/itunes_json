import ArgumentParser
import Foundation

public struct Program: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: String(localized: "tunes", bundle: .module),
    abstract: String(localized: "A tool for working with iTunes data.", bundle: .module),
    version: iTunesVersion,
    subcommands: [
      BackupCommand.self, PatchCommand.self, RepairCommand.self, BatchCommand.self,
      QueryCommand.self, ArchiveCommand.self,
    ],
    defaultSubcommand: BackupCommand.self
  )

  public init() {}  // This is public and empty to help the compiler.
}
