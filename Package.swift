// swift-tools-version:5.10

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
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.4.0")
  ],
  targets: [
    .target(
      name: "iTunes",
      swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
    .testTarget(name: "iTunesTests", dependencies: ["iTunes"]),
    .executableTarget(
      name: "tool",
      dependencies: [
        .byName(name: "iTunes"), .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
