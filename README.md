# `mt` — Swift Metal library with C++ interoperability

`mt` is a macOS Metal library implemented in Swift and exposed to C++ through
Swift's generated C++ interoperability header.

The project follows Metal's native ownership model:

```text
Device → CommandQueue → CommandBuffer → Encoders
```

The core does not require a global Vulkan-style context, Swift source
integration in consuming C++ projects, AppKit, or `MTKView`.

## Requirements

- macOS 13+
- CMake 3.26+ with a Swift 5.9-compatible toolchain
- Clang/Xcode toolchain for C++ interoperability

The core Metal module uses Swift's `Metal` framework APIs. C++ consumers link
the Swift library and include the generated `MTCore-Swift.h` through
`include/mt/mt.hpp`.

## Repository layout

```text
Sources/MTCore/       # Swift Metal implementation
tests/MTCoreTests/    # Swift-side unit/runtime tests
include/mt/           # C++ umbrella and generated-header aliases
tests/                # C++ header and package-consumer tests
examples/             # External C++ consumer examples
docs/plans/           # Module implementation plans
```

## Build/package shape

The CMake target:

- builds the Swift `MTCore` library;
- enables Swift/C++ interoperability;
- generates `MTCore-Swift.h`;
- installs the Swift library, generated header, C++ aliases, and CMake package
  configuration.

SwiftPM support is also provided through `Package.swift`.

Build and runtime verification are intentionally pending on a Metal-capable
machine. See [`docs/plans/README.md`](docs/plans/README.md) for the staged
implementation and test plan.
