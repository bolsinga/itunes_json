//
//  main.swift
//
//
//  Created by Greg Bolsinga on 12/11/23.
//

import Foundation

let command = Program.parseOrExit()
do {
  try await command.run()
} catch {
  Program.exit(withError: error)
}
