// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "itunes_json",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "iTunes", targets: ["iTunes"]),
    .executable(name: "itunes_json", targets: ["tool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
  ],
  targets: [
    .target(name: "iTunes"),
    .testTarget(name: "iTunesTests", dependencies: ["iTunes"]),
    .executableTarget(
      name: "tool",
      dependencies: [
        .byName(name: "iTunes"), .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
