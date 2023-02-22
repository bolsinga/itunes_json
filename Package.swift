// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "itunes_json",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.4")
  ],
  targets: [
    .executableTarget(
      name: "itunes_json",
      dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")])
  ]
)
