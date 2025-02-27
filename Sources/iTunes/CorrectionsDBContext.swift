//
//  CorrectionsDBContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/23/25.
//

import Foundation

struct CorrectionsDBContext: FlatDBEncoderContext {
  let storage: DatabaseStorage

  var context: Database.Context {
    Database.Context(storage: storage, loggingToken: nil)
  }

  func insertStatement(_ item: IdentifierCorrection) -> Database.Statement {
    CorrectionsDBRow.insertStatement(item)
  }

  func row(for item: IdentifierCorrection) -> CorrectionsDBRow {
    CorrectionsDBRow(correction: item)
  }

  var schema: String = """
    CREATE TABLE IF NOT EXISTS correct_id (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value TEXT,
      CHECK(length(value) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_song (
      itunesid TEXT NOT NULL PRIMARY KEY,
      name TEXT,
      sort TEXT,
      CHECK(length(name) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_artist (
      itunesid TEXT NOT NULL PRIMARY KEY,
      name TEXT,
      sort TEXT,
      CHECK(length(name) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_album (
      itunesid TEXT NOT NULL PRIMARY KEY,
      name TEXT,
      sort TEXT,
      CHECK(length(name) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_tracknumber (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS correct_trackcount (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS correct_discnumber (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS correct_disccount (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS correct_year (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS correct_duration (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS correct_added (
      itunesid TEXT NOT NULL PRIMARY KEY,
      date TEXT,
      CHECK(length(date) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_compilation (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value INTEGER,
      CHECK(value = 0 OR value = 1)
    );
    CREATE TABLE IF NOT EXISTS correct_composer (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value TEXT,
      CHECK(length(value) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_released (
      itunesid TEXT NOT NULL PRIMARY KEY,
      date TEXT,
      CHECK(length(date) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_comment (
      itunesid TEXT NOT NULL PRIMARY KEY,
      value TEXT,
      CHECK(length(value) > 0)
    );
    CREATE TABLE IF NOT EXISTS correct_play (
      itunesid TEXT NOT NULL PRIMARY KEY,
      olddate TEXT,
      oldcount INTEGER,
      newdate TEXT,
      newcount INTEGER,
      CHECK(length(olddate) > 0),
      CHECK(length(newdate) > 0)
    );
    """
}
