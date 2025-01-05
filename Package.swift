// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "itunes_json",
  platforms: [
    .macOS(.v15),
    .iOS(.v18),
  ],
  products: [
    .library(name: "iTunes", targets: ["iTunes"]),
    .executable(name: "tunes", targets: ["tunes"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    .package(url: "https://github.com/bolsinga/GitLibrary", from: "1.1.2"),
    .package(url: "https://github.com/DimaRU/PackageBuildInfo", from: "1.0.4"),
  ],
  targets: [
    .target(
      name: "iTunes",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "GitLibrary", package: "GitLibrary"),
      ],
      plugins: [.plugin(name: "PackageBuildInfoPlugin", package: "PackageBuildInfo")]),
    .testTarget(name: "iTunesTests", dependencies: ["iTunes"]),
    .executableTarget(name: "tunes", dependencies: [.byName(name: "iTunes")]),
  ]
)
