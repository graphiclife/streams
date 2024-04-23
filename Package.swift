// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "streams",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "streams", targets: ["streams"]),
    ],
    dependencies: [
      .package(name: "gstreamer-swift", path: "/Users/mans.severin/Documents/Projects/Swift/gstreamer-swift"),
    ],
    targets: [
        .target(name: "streams", dependencies: [
            .product(name: "gstreamer-swift", package: "gstreamer-swift"),
        ], swiftSettings: [
            .unsafeFlags(["-enable-bare-slash-regex"])
        ]),
        .testTarget(name: "streamsTests", dependencies: [
            "streams"
        ]),
    ]
)
