// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "itunes_json",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "iTunes", targets: ["iTunes"]),
    .executable(name: "tool", targets: ["tool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2")
  ],
  targets: [
    .target(name: "iTunes"),
    .executableTarget(
      name: "tool",
      dependencies: [
        .byName(name: "iTunes"), .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
