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
        .package(url: "https://github.com/graphiclife/gstreamer-swift.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "streams", dependencies: [
            .product(name: "gstreamer-swift", package: "gstreamer-swift"),
        ], swiftSettings: [
            .enableUpcomingFeature("BareSlashRegexLiterals")
        ]),
        .testTarget(name: "streamsTests", dependencies: [
            "streams"
        ]),
    ]
)
