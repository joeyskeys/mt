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
        ),
        .library(
            name: "MTAppKit",
            type: .dynamic,
            targets: ["MTAppKit"]
        ),
        .library(
            name: "MTMetalKit",
            type: .dynamic,
            targets: ["MTMetalKit"]
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
        .target(
            name: "MTAppKit",
            dependencies: ["MTCore"],
            path: "Sources/MTAppKit",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Metal"),
                .linkedFramework("QuartzCore")
            ]
        ),
        .target(
            name: "MTMetalKit",
            dependencies: ["MTCore"],
            path: "Sources/MTMetalKit",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
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

