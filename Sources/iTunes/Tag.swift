//
//  Tag.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/17/25.
//

struct Tag<Item: Sendable>: Tagged, Sendable {
  let tag: String
  let item: Item
}
