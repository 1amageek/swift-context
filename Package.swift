// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-context",
    platforms: [
        .iOS(.v18), .macOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftContext",
            targets: ["SwiftContext"]),
        .executable(
            name: "cli",
            targets: ["cli"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "SwiftContext",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]),
        .executableTarget(
            name: "cli",
            dependencies: [
                "SwiftContext",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "SwiftContextTests",
            dependencies: ["SwiftContext"]
        ),
    ]
)
