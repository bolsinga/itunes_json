import ArgumentParser
import Foundation
import iTunes

@main
public struct Program: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    abstract: "A tool for working with iTunes data.",
    subcommands: [BackupCommand.self, PatchCommand.self, RepairCommand.self, BatchCommand.self],
    defaultSubcommand: BackupCommand.self
  )

  public init() {}  // This is public and empty to help the compiler.
}
