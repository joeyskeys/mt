# Plan 01 — Build system and C++ ABI

**Status:** implemented — Swift-first migration in progress; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** none

## Goal

Make `mt` a macOS Swift library whose supported public API can be consumed by
another C++20 project through Swift's generated C++ interoperability header.

This module establishes the Swift/module/package boundary. It does not
implement rendering behavior beyond the smallest device/queue smoke test.

## Responsibilities

- Installable Swift library target and CMake package.
- Generated C++ header plus a small `include/mt/` alias/umbrella layer.
- Swift Metal implementation target.
- Framework linkage and deployment-target policy.
- Swift/C++ interop-compatible ownership and native-handle boundary.
- Swift runtime/linkage and ABI conventions.
- External consumer example.

## Non-goals

- AppKit window creation.
- A renderer or scene manager.
- A global `Context`.
- Exposing all Metal protocol types in the generated C++ header.
- Shipping an application demo as part of the core library target.

## Proposed targets

The exact target names can change, but the dependency shape should be:

```text
mt::mt                  # Swift Metal library + generated C++ header
mt::mt-shaders          # optional shader packaging helpers
mt::mt-appkit            # optional CAMetalLayer/AppKit adapter
mt::mt-mtkview           # optional MTKView adapter
mt::mt-renderer          # higher-level renderer modules
mt::mt-viewport          # viewport and picking modules
mt::mt-imgui             # optional ImGui integration
```

The first implementation creates the Swift `mt::mt` target, its generated
header, and one external consumer/example target. Optional targets must not
leak into the core target's Swift API or dependencies.

## Public header policy

Public headers must:

- compile as C++20 with the generated Swift support header available;
- contain only small aliases/adapters around generated Swift types;
- avoid exposing Swift implementation details or Objective-C protocol types;
- document which generated Swift types are copyable, movable, or
  reference-counted from C++;
- keep the generated header out of source control.

Suggested initial headers:

```text
include/mt/
  mt.hpp
  swift_api.hpp
  native_handle.hpp
  device.hpp
  command_queue.hpp
  command_buffer.hpp
  surface.hpp
```

The later plans add resource, pipeline, renderer, scene, and viewport headers.

## Swift/C++ binding strategy

The selected strategy is a Swift-first core:

- Swift owns all Metal objects and calls the Metal framework directly.
- Swift target compilation uses `-cxx-interoperability-mode=default`.
- CMake/SwiftPM/Xcode generate a `MTCore-Swift.h` compatibility header.
- C++ consumers include that generated header through `mt/mt.hpp`.
- Swift classes provide reference-counted object handles to C++.
- Swift structs/enums provide capability and descriptor values.
- Native Metal pointers are exposed only as borrowed opaque pointers.

The generated header is part of the build/install output, not source control.
The public Swift API must use only types supported by Swift/C++ interop. A
Swift-only convenience API may exist internally, but it must not be part of
the C++-visible public declarations.

### Decision record

This decision records:

- Swift is the implementation language for the core Metal module.
- C++ interop is enabled in the library target.
- C++ consumers link the Swift library and required Swift runtime/frameworks.
- The generated header is compiler/module-version-specific.
- Objective-C++ is not part of the active core implementation.
- The minimum Swift toolchain/Xcode SDK and macOS deployment target are
  macOS 13 and Swift 5.9-compatible, subject to later upgrade.

## CMake design

The core CMake target should:

- enable C++ and Swift languages;
- build the Swift `MTCore` library target;
- enable Swift/C++ interoperability;
- generate the C++ header with CMake's Swift support;
- link Metal and Foundation, with QuartzCore for the layer-backed surface
  boundary and MetalKit only in optional adapters;
- export include directories, generated header, and transitive linkage;
- install the Swift library and generated package configuration;
- support Debug and Release;
- document Swift runtime/framework requirements for external consumers.

Illustrative consumer shape:

```cmake
find_package(mt CONFIG REQUIRED)

add_executable(example main.cpp)
target_link_libraries(example PRIVATE mt::mt)
```

The example should compile from outside the repository using the installed
generated header and exported Swift library target. It must not include Swift
source or depend on Objective-C++.

## ABI and lifetime conventions

Define these before adding more Swift wrappers:

- Swift classes own or retain their native Metal objects.
- C++ generated wrappers follow Swift reference-counted lifetime semantics.
- Swift structs/enums are copied by value.
- Native handles are borrowed and never transfer ownership.
- Objects referenced by in-flight command buffers remain retained by Swift
  until Metal releases them.
- Swift errors must be represented by C++-visible optionals/status values or
  dedicated interop-compatible types.
- The generated header and Swift runtime version are part of the package ABI.

Do not promise a stable ABI across arbitrary Swift compiler versions. Package
the library and generated header from the same build/toolchain, and document
that C++ consumers must use a compatible Clang/Swift runtime environment.

## Implementation steps

1. Add the Swift `MTCore` target and C++ interoperability setting.
2. Add CMake/SwiftPM package helpers.
3. Generate and install `MTCore-Swift.h`.
4. Link Metal and Foundation through the Swift target/package.
5. Add install/export rules and an external C++ consumer example.
6. Add generated-header compile tests and Swift unit tests.
7. Record Swift toolchain/runtime requirements.
8. Add CI or local scripts for Debug, Release, install, and external consume.

## Acceptance criteria

- `cmake --install` produces headers, a library, and a usable package config.
- An external C++20 project can find and link `mt::mt`.
- The external project does not include Swift source, AppKit, or `MTKView`.
- The generated public header compiles as C++20.
- Framework linkage is transitive and documented.
- Swift ownership, generated-header compatibility, and runtime requirements are
  documented.
- The target can be built independently from any application or host adapter.

## Implementation in this slice

Implemented in the Swift-first migration slice:

- Swift `MTCore` target with Metal device/queue/command-buffer wrappers;
- Swift/C++ interoperability compiler configuration;
- generated `MTCore-Swift.h` integration through CMake;
- C++ umbrella/alias headers under `include/mt/`;
- Swift unit tests for capability and no-device behavior;
- C++ header/consumer test targets retained for package integration.

The generated-header/package path and Swift runtime linkage remain intentionally
unverified until a Metal-capable macOS machine is available.

## Decisions recorded by Plan 12

- The installed CMake package is named `mt`, exports `mt::mt`, and currently
  uses project version `0.1.0`.
- CMake is the canonical installed C++ distribution path; SwiftPM is the
  canonical Swift distribution path.
- The public C++ ABI is the generated Swift interoperability header for the
  supported Swift 5.9-compatible/macOS 13 toolchain range.
- Source MSL is packaged for consumers and compiled into deployment-specific
  metallibs through the installed CMake helper.

Long-term ABI compatibility across Swift compiler versions and release policy
remain subject to the evidence collected by
[Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).

