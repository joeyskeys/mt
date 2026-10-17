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

The public ABI is the generated Swift C++ interoperability header for the
declared Swift toolchain/SDK range (currently Swift 5.9-compatible tooling,
macOS 13+). The CMake package is the canonical installed C++ distribution
path; SwiftPM remains the canonical Swift distribution path. Generated headers
are build artifacts and must be regenerated when the Swift compiler or public
module changes. The installed C++ package is named `mt`, exports `mt::mt`, and
currently uses project version `0.1.0`.

## Repository layout

```text
Sources/MTCore/       # Swift Metal implementation and renderer layer
Sources/MTAppKit/     # Optional AppKit/CAMetalLayer adapter
Sources/MTMetalKit/   # Optional MTKView adapter
tests/MTCoreTests/    # Swift-side unit/runtime tests
include/mt/           # C++ umbrella and generated-header aliases
tests/                # C++ header and package-consumer tests
examples/             # External C++ consumer examples
shaders/built_in/     # Source-controlled built-in MSL
docs/plans/           # Module implementation plans
docs/capability-matrix.md # Metal-device verification record
```

## Build/package shape

The CMake target:

- builds the Swift `MTCore` library;
- enables Swift/C++ interoperability;
- generates `MTCore-Swift.h`;
- installs the Swift library, generated header, C++ aliases, and CMake package
  configuration;
- installs source-controlled built-in MSL under
  `share/mt/shaders/built_in` for packaging with `mt_add_metallib()`.

After `find_package(mt CONFIG REQUIRED)`, consumers can use the installed
`mt_add_metallib()` helper to compile MSL sources into a packaged metallib.
Release applications should prefer those precompiled libraries; runtime MSL
compilation is intended for development and diagnostics.

Metal-native extensions are exposed through `mt/metal.hpp`, including
capability records, mesh dispatch, argument buffers, indirect command buffers,
tile pipelines, memoryless/imageblock render-pass configuration,
acceleration-structure builds and intersection-function tables, counter sample
buffers, SIMD-group family records, and command-buffer GPU timing. Each
extension is capability-gated at runtime. The focused
`mt/acceleration_structure.hpp` and `mt/counter.hpp` headers are also
available for consumers that do not include the aggregate header.

Shader and pipeline completion APIs are exposed through `mt/shader.hpp`,
`mt/binding.hpp`, `mt/pipeline.hpp`, `mt/pipeline_cache.hpp`,
`mt/binary_archive.hpp`, and `mt/depth_stencil.hpp`. They preserve Metal
function specialization,
argument-buffer arrays and nested tables, device-scoped pipeline caches,
binary archives, dynamic-library linking, and depth/stencil state objects.

The renderer layer is available through `mt/renderer.hpp`. It provides
explicit Forward/Forward+ pass scheduling, clustered-light preparation and
consumption, deterministic CPU/GPU culling contracts, material and
argument-table binding, meshlet/native mesh submission, persistent statistics,
pipeline-cache integration, resize tracking, and capability-aware
indexed/mesh/indirect paths without owning a window or command queue.

The core transfer/lifetime layer is available through `mt/transfer.hpp` and
`mt/lifetime.hpp`. It provides validated buffer ranges, texture subresources,
explicit staging and drawable readback, completion polling, resource
retirement/versioning, and an optional typed registry. Private resources are
transferred through explicit blit operations.

The scene and asset layer is available through `mt/scene.hpp`,
`mt/assets.hpp`, `mt/material.hpp`, `mt/lights.hpp`, and
`mt/built_in_shaders.hpp`. It provides CPU-side scenes, procedural meshes,
explicit shared/managed GPU uploads, materials, lights, and stable metadata
for built-in MSL entry points. CPU scene ownership remains separate from
device and command-buffer ownership.

The viewport and picking layer is available through `mt/viewport.hpp` and
`mt/picking.hpp`. It provides explicit picking/scene/overlay phases, feature
lifecycle state, offscreen RGBA8 ID targets, and polled readback without
owning a window, surface, command queue, or renderer.

Host integration is optional. Enable `MT_BUILD_APPKIT` or
`MT_BUILD_MTKVIEW` to build `mt::mt-appkit` or `mt::mt-mtkview`; these adapters
configure borrowed AppKit/CAMetalLayer or MTKView handles while preserving
application-owned queues and frame loops. Toolkit-neutral input events are
available from `mt/input.hpp`.

SwiftPM support is also provided through `Package.swift`.

The standalone installed-package consumer can be enabled with
`MT_BUILD_INSTALLED_CONSUMER=ON`; it performs a separate
`find_package(mt CONFIG REQUIRED)` configure/build against the installed
package. The capability record template is in
`docs/capability-matrix.md`.

Build and runtime verification are intentionally pending on a Metal-capable
machine. See [`docs/plans/README.md`](docs/plans/README.md) for the staged
implementation and test plan.
