// swift-tools-version:6.3

import PackageDescription

let package = Package(
  name: "itunes_json",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
  ],
  products: [
    .library(name: "iTunes", targets: ["iTunes"]),
    .executable(name: "tunes", targets: ["tunes"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
    .package(url: "https://github.com/bolsinga/GitLibrary", exact: "1.1.3"),
    .package(url: "https://github.com/bolsinga/PackageBuildInfo", exact: "2.0.1"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.6.0"),
  ],
  targets: [
    .target(
      name: "iTunes",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "GitLibrary", package: "GitLibrary"),
      ],
      resources: [.process("Resources/Localizable.xcstrings")],
      plugins: [.plugin(name: "PackageBuildInfoPlugin", package: "PackageBuildInfo")]),
    .testTarget(name: "iTunesTests", dependencies: ["iTunes"]),
    .executableTarget(name: "tunes", dependencies: [.byName(name: "iTunes")]),
  ]
)
