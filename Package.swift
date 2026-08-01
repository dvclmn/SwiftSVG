// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "SwiftSVG",
  platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
  products: [
    .library(
      name: "SwiftSVG",
      targets: ["SwiftSVG"]
    )
  ],
  targets: [
    .target(
      name: "SwiftSVG",
      dependencies: [],
      path: "SwiftSVG",
      resources: [.process("Resources/cssColorNames.json")],
    ),
    .testTarget(
      name: "SwiftSVGTests",
      dependencies: ["SwiftSVG"],
      path: "SwiftSVGTests"
    ),
  ],
)
