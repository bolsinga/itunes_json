//
//  main.swift
//
//
//  Created by Greg Bolsinga on 12/11/23.
//

import Foundation

func readSTDIN() -> String? {
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

var text: String?

if CommandLine.arguments.last == "-" {
  CommandLine.arguments.removeLast()

  text = readSTDIN()
}

var arguments = Array(CommandLine.arguments.dropFirst())
if let text = text {
  arguments.insert(text, at: 0)
}

let command = Program.parseOrExit(arguments)
do {
  try await command.run()
} catch {
  Program.exit(withError: error)
}
