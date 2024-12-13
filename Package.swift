// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "itunes_json",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .library(name: "iTunes", targets: ["iTunes"]),
    .executable(name: "itunes_json", targets: ["tool"]),
    .executable(name: "repair", targets: ["repair"]),
    .executable(name: "batch", targets: ["batch"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
  ],
  targets: [
    .target(
      name: "iTunes",
      dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
    .testTarget(name: "iTunesTests", dependencies: ["iTunes"]),
    .executableTarget(name: "tool", dependencies: [.byName(name: "iTunes")]),
    .executableTarget(name: "repair", dependencies: [.byName(name: "iTunes")]),
    .executableTarget(name: "batch", dependencies: [.byName(name: "iTunes")]),
  ]
)
