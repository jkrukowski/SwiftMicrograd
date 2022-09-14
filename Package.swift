// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SwiftMicrograd",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "SwiftMicrograd",
            targets: ["SwiftMicrograd"]
        ),
        .library(
            name: "SwiftMicrogradGraph",
            targets: ["SwiftMicrogradGraph"]
        ),
        .executable(
            name: "SwiftMicrogradCLI",
            targets: ["SwiftMicrogradCLI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/SwiftDocOrg/GraphViz",
            from: "0.4.1"
        ),
        .package(
            url: "https://github.com/damuellen/Gnuplot.swift.git",
            from: "0.3.0"
        ),
        .package(
            url: "https://github.com/apple/swift-numerics",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "SwiftMicrogradCLI",
            dependencies: [
                .target(name: "SwiftMicrograd"),
                .target(name: "SwiftMicrogradGraph"),
                .product(name: "Gnuplot", package: "Gnuplot.swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [
                .copy("data.json")
            ]
        ),
        .target(
            name: "SwiftMicrograd",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .target(
            name: "SwiftMicrogradGraph",
            dependencies: [
                .target(name: "SwiftMicrograd"),
                .product(name: "GraphViz", package: "GraphViz")
            ]
        ),
        .testTarget(
            name: "SwiftMicrogradTests",
            dependencies: ["SwiftMicrograd"]
        )
    ]
)
