// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "itunes_json",
  defaultLocalization: "en",
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
    .package(url: "https://github.com/bolsinga/PackageBuildInfo", exact: "2.0.0"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4"),
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
