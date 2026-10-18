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
        ),
        .library(
            name: "MTImGui",
            type: .dynamic,
            targets: ["MTImGui"]
        ),
        .library(
            name: "MTText",
            type: .dynamic,
            targets: ["MTText"]
        ),
        .library(
            name: "MTFreeType",
            type: .dynamic,
            targets: ["MTFreeType"]
        ),
        .library(
            name: "MTAssetPipeline",
            type: .dynamic,
            targets: ["MTAssetPipeline"]
        ),
        .library(
            name: "MTExternalResources",
            type: .dynamic,
            targets: ["MTExternalResources"]
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
                .linkedFramework("AppKit"),
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
                .linkedFramework("QuartzCore")
            ]
        ),
        .target(
            name: "MTImGui",
            dependencies: ["MTCore"],
            path: "Sources/MTImGui",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "MTText",
            dependencies: ["MTCore"],
            path: "Sources/MTText",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreText"),
                .linkedFramework("Foundation")
            ]
        ),
        .target(
            name: "MTFreeType",
            dependencies: ["MTCore", "MTText"],
            path: "Sources/MTFreeType",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "MTAssetPipeline",
            dependencies: ["MTCore"],
            path: "Sources/MTAssetPipeline",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("Foundation")
            ]
        ),
        .target(
            name: "MTExternalResources",
            dependencies: ["MTCore"],
            path: "Sources/MTExternalResources",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("IOSurface"),
                .linkedFramework("Metal")
            ]
        ),
        .testTarget(
            name: "MTCoreTests",
            dependencies: ["MTCore"],
            path: "tests/MTCoreTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "MTAppKitTests",
            dependencies: ["MTAppKit"],
            path: "tests/MTAppKitTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "MTMetalKitTests",
            dependencies: ["MTMetalKit"],
            path: "tests/MTMetalKitTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "MTImGuiTests",
            dependencies: ["MTImGui"],
            path: "tests/MTImGuiTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "MTTextTests",
            dependencies: ["MTText"],
            path: "tests/MTTextTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "MTFreeTypeTests",
            dependencies: ["MTFreeType"],
            path: "tests/MTFreeTypeTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "MTAssetPipelineTests",
            dependencies: ["MTAssetPipeline"],
            path: "tests/MTAssetPipelineTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "MTExternalResourcesTests",
            dependencies: ["MTExternalResources"],
            path: "tests/MTExternalResourcesTests",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        )
    ]
)

