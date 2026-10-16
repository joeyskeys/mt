// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MTCore",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MTCore",
            type: .dynamic,
            targets: ["MTCore"]
        )
    ],
    targets: [
        .target(
            name: "MTCore",
            path: "Sources/MTCore",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("Metal"),
                .linkedFramework("QuartzCore")
            ]
        ),
        .testTarget(
            name: "MTCoreTests",
            dependencies: ["MTCore"],
            path: "tests/MTCoreTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        )
    ]
)

