// swift-tools-version:6.4

import PackageDescription

let package = Package(
  name: "itunes_json",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v27),
    .iOS(.v27),
  ],
  products: [
    .library(name: "iTunes", targets: ["iTunes"]),
    .executable(name: "tunes", targets: ["tunes"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.8.2"),
    .package(url: "https://github.com/bolsinga/GitLibrary", exact: "3.0.0"),
    .package(url: "https://github.com/bolsinga/PackageBuildInfo", exact: "3.0.1"),
    .package(url: "https://github.com/apple/swift-collections.git", exact: "1.7.1"),
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
