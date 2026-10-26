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

The commands below must run on macOS with the Metal SDK available. The
repository intentionally does not provide a non-Apple build; runtime checks
also need a Mac with a usable Metal device.

## Build from source

Run these commands from the repository root. Use CMake when you are building
the C++ package or its generated interoperability headers. Use SwiftPM when
you are developing against the Swift products or running the Swift test
targets.

### CMake Debug build

Configure the core library, C++ tests, and examples:

```sh
cmake -S . -B build/cmake-debug \
  -DCMAKE_BUILD_TYPE=Debug \
  -DMT_BUILD_TESTS=ON \
  -DMT_BUILD_EXAMPLES=ON
```

Build and run the CMake test suite:

```sh
cmake --build build/cmake-debug --config Debug
ctest --test-dir build/cmake-debug \
  --build-config Debug \
  --output-on-failure
```

The default configuration builds the `mt::mt` library, the public-header and
external-consumer checks, `mt-example-consumer-smoke`, and
`mt-example-runtime-smoke`. Build an individual example with its CMake target:

```sh
cmake --build build/cmake-debug \
  --config Debug \
  --target mt-example-runtime-smoke
```

Run the capability-aware launcher with an entry point from
[`examples/validation-matrix.json`](examples/validation-matrix.json), for
example:

```sh
./build/cmake-debug/examples/mt-example-runtime-smoke device_info
```

When using a multi-configuration generator such as Xcode, the executable is
under the generator's configuration directory, usually
`build/cmake-debug/Debug/examples/`.

### Release build and installation

Use a separate build directory for Release artifacts:

```sh
cmake -S . -B build/cmake-release \
  -DCMAKE_BUILD_TYPE=Release \
  -DMT_BUILD_TESTS=ON \
  -DMT_BUILD_EXAMPLES=ON
cmake --build build/cmake-release --config Release
cmake --install build/cmake-release \
  --config Release \
  --prefix "$PWD/install/mt"
```

Installation produces the Swift library, generated `MTCore-Swift.h`, C++
facade headers, built-in MSL, and the `mt` CMake package configuration. Do not
copy the generated header from a previous build: it must match the Swift
compiler, SDK, and public Swift declarations used to build the library.

To validate the installed package as an external project, enable the installed
consumer test and run CTest:

```sh
cmake -S . -B build/cmake-package \
  -DCMAKE_BUILD_TYPE=Debug \
  -DMT_BUILD_TESTS=ON \
  -DMT_BUILD_EXAMPLES=ON \
  -DMT_BUILD_INSTALLED_CONSUMER=ON
cmake --build build/cmake-package --config Debug
ctest --test-dir build/cmake-package \
  --build-config Debug \
  --output-on-failure \
  -R 'mt\.consumer\.installed'
```

The installed-consumer check installs into a build-local prefix, configures a
separate project with `find_package(mt CONFIG REQUIRED)`, builds it against
the installed files, and runs a headless command-buffer/offscreen fixture.

### SwiftPM build and tests

SwiftPM exposes the Swift products declared in `Package.swift`:

```sh
swift build --package-path . --configuration debug
swift test --package-path . --configuration debug
swift build --package-path . --configuration release
```

### Repeatable package validation

For the complete local validation used by the project, run:

```sh
bash scripts/validate_package.sh
```

This creates separate CMake Debug and Release builds, runs their CTest suites
with the installed-consumer check enabled, then runs SwiftPM debug tests and a
SwiftPM Release build. Set `MT_VALIDATION_BUILD_ROOT` to place the generated
validation builds elsewhere. Optional integrations are enabled explicitly:

| Environment variable | Effect |
| --- | --- |
| `MT_VALIDATE_OPTIONAL_HOSTS=1` | Validate AppKit, MTKView, and native host examples |
| `MT_VALIDATE_GUI_TEXT=1` | Validate ImGui, CoreText, and FreeType bridge targets |
| `MT_VALIDATE_ASSET_PIPELINE=1` | Validate the asset-pipeline target and example |
| `MT_VALIDATE_EXTERNAL_RESOURCES=1` | Validate the IOSurface target |
| `MT_VALIDATE_PYTHON=1` | Validate Python; also set `MT_PYTHON_EXECUTABLE` |

These commands are intended for a Metal-capable Mac. Unsupported GPU
capabilities are reported as fallbacks by the runtime validation paths rather
than being silently counted as native feature passes.

### Optional CMake targets

Optional integrations stay disabled unless their dependencies and contracts
are wanted by the application. Add the relevant options to a fresh CMake
configuration:

| Option | Default | Enables |
| --- | --- | --- |
| `MT_BUILD_APPKIT` | `OFF` | `mt::mt-appkit` and the AppKit/CAMetalLayer adapter |
| `MT_BUILD_MTKVIEW` | `OFF` | `mt::mt-mtkview` and the MTKView adapter |
| `MT_BUILD_HOST_EXAMPLES` | `OFF` | Native AppKit/MTKView window consumers; also requires the corresponding adapter |
| `MT_BUILD_IMGUI` | `OFF` | `mt::mt-imgui` coordination boundary |
| `MT_BUILD_TEXT` | `OFF` | `mt::mt-text` CoreText glyph/atlas/mesh layer |
| `MT_BUILD_FREETYPE_BRIDGE` | `OFF` | `mt::mt-freetype`; it also enables `MT_BUILD_TEXT` |
| `MT_BUILD_GUI_TEXT_EXAMPLES` | `OFF` | ImGui-boundary and text-atlas examples |
| `MT_BUILD_ASSET_PIPELINE` | `OFF` | `mt::mt-asset-pipeline` |
| `MT_BUILD_ASSET_PIPELINE_EXAMPLES` | `OFF` | Asset-pipeline consumer example; also requires `MT_BUILD_ASSET_PIPELINE` |
| `MT_BUILD_EXTERNAL_RESOURCES` | `OFF` | `mt::mt-external-resources` and IOSurface support |
| `MT_BUILD_PYTHON` | `OFF` | The optional CPython extension |
| `MT_BUILD_INSTALLED_CONSUMER` | `OFF` | The separate installed-package CTest |

For optional examples and the ownership rules of each integration, see
[`examples/README.md`](examples/README.md) and the contracts under
[`docs/integrations/`](docs/integrations/).

## Use from C++

The installed CMake package is the supported C++ consumption path. A consumer
should include `mt/mt.hpp`, link `mt::mt`, and never include the generated
`MTCore-Swift.h` directly.

### Minimal C++ consumer

After installing the project as shown above, a downstream `CMakeLists.txt`
can use the package like this:

```cmake
cmake_minimum_required(VERSION 3.26)
project(mt_example LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(mt CONFIG REQUIRED)

add_executable(mt-example main.cpp)
target_link_libraries(mt-example PRIVATE mt::mt)
```

Configure the downstream project with the installation prefix:

```sh
cmake -S . -B build \
  -DCMAKE_PREFIX_PATH="/absolute/path/to/install/mt"
cmake --build build
```

`main.cpp` can start with a device, queue, and command-buffer ownership
sequence like this:

```cpp
#include <iostream>

#include <mt/mt.hpp>

int main() {
    const auto devices = mt::Device::enumerate();
    auto device = mt::Device::systemDefault();
    if (!device) {
        std::cerr << "No Metal device is available\n";
        return devices.empty() ? 0 : 1;
    }

    auto queue = device->createCommandQueue();
    if (!queue) {
        return 2;
    }

    auto commandBuffer = queue->makeCommandBuffer();
    if (!commandBuffer || !commandBuffer->commit()) {
        return 3;
    }

    commandBuffer->waitUntilCompleted();
    return commandBuffer->didSucceed() ? 0 : 4;
}
```

For real rendering, create encoders from the command buffer, encode resource
and pipeline work, end each encoder, then commit the buffer. Applications
should normally use completion tokens or polling instead of blocking every
frame with `waitUntilCompleted()`.

### Ownership and capability rules

- The application owns the device, command queue, command buffers, renderer,
  frame loop, and event loop. The core has no global context.
- `Device::enumerate()` reports available devices and
  `Device::systemDefault()` selects the system default. Check the returned
  device and queue/command-buffer results before using them.
- Query `device->capabilities()` before selecting mesh shaders, argument
  buffers, indirect command buffers, tile/memoryless paths, ray tracing, or
  other Metal-native extensions. Select and report an explicit fallback when a
  capability is unavailable.
- The core is window-system neutral. Enable the AppKit or MTKView targets only
  when the application wants an adapter around a borrowed native view/layer.
  Drawable acquisition, resize handling, presentation, and command-buffer
  submission remain explicit in the application.
- `mt/mt.hpp` is the aggregate public C++ surface. The focused headers such as
  `mt/renderer.hpp`, `mt/scene.hpp`, `mt/viewport.hpp`, and
  `mt/picking.hpp` can be included when a consumer wants a narrower dependency
  surface.

### Compiled Metal shaders

Installed consumers can use the packaged `mt_add_metallib()` helper to compile
MSL at build time:

```cmake
find_package(mt CONFIG REQUIRED)

mt_add_metallib(app_shaders
  SOURCES shaders/app.metal
  INSTALL_DESTINATION share/my-app/shaders
)
add_dependencies(mt-example app_shaders)
```

The helper uses `xcrun metal` and `xcrun metallib`, exposes the generated path
as `app_shaders_METALLIB`, and can install the resulting library. Prefer
precompiled metallibs for Release applications; runtime MSL compilation is
intended for development and diagnostics.

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
Sources/MTAssetPipeline/ # Optional importer/conversion/serialization values
Sources/MTExternalResources/ # Optional IOSurface/imported-resource adapter
python/               # Optional CPython extension source
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

Optional Python builds install the `mt` extension separately and export it
through `mtPythonTargets.cmake`; ordinary `find_package(mt)` consumers remain
Python-free until they call `mt_enable_python()`. Optional IOSurface builds
export `mt::mt-external-resources` and install its generated facade only when
`MT_BUILD_EXTERNAL_RESOURCES=ON`.

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
`mt/built_in_shaders.hpp`. It provides CPU-side scenes, indexed and optional
meshlet geometry, curves, versioned GPU synchronization with completion-backed
retirement, procedural fixtures, material resource tables, clustered-light and
shadow contracts, and stable metadata for built-in MSL entry points. CPU scene
ownership remains separate from device and command-buffer ownership.

The viewport and picking layer is available through `mt/viewport.hpp` and
`mt/picking.hpp`. It provides explicit picking/scene/overlay phases, feature
lifecycle state, GPU axes/grid/label/point features, automatic scene
object/vertex ID passes, deterministic CPU vertex selection, optional depth
and normal attachments, capability-selected Metal acceleration metadata, and
polled readback without owning a window, surface, command queue, or renderer.
When fragment atomics are available, it also provides a bounded linked-list
A-buffer path that returns overlapping object/vertex hits and reports node
pool overflow explicitly; the RGBA8 path remains the fallback.
Value-only feature extensions and an editor-style offscreen fixture are also
provided for applications that need to compose custom viewport work.

Host integration is optional. Enable `MT_BUILD_APPKIT` or
`MT_BUILD_MTKVIEW` to build `mt::mt-appkit` or `mt::mt-mtkview`; these adapters
configure borrowed AppKit/CAMetalLayer or MTKView handles while preserving
application-owned queues and frame loops. Toolkit-neutral input events are
available from `mt/input.hpp`, and native window consumers can be enabled with
`MT_BUILD_HOST_EXAMPLES`. See
[`docs/integrations/native-host-contract.md`](docs/integrations/native-host-contract.md)
for ownership, resize, drawable-loss, scale, and event-translation rules.

GUI and text integrations are separate opt-in targets:
`MT_BUILD_IMGUI` installs the ImGui coordination boundary,
`MT_BUILD_TEXT` installs the CoreText glyph/atlas/mesh layer, and
`MT_BUILD_FREETYPE_BRIDGE` installs the value-only FreeType bridge. Their
headers are `mt/imgui.hpp`, `mt/text.hpp`, and `mt/freetype.hpp`; none are
included by `mt/mt.hpp`. See
[`docs/integrations/gui-text-contract.md`](docs/integrations/gui-text-contract.md)
for dependency ownership and lifetime rules.

Asset-pipeline integration is also opt-in through
`MT_BUILD_ASSET_PIPELINE`. It installs `mt/asset_pipeline.hpp` and provides
normalized importer values, coordinate/material/texture conversion, versioned
JSON serialization, and a small P5/P6 fixture loader. Assimp, image codecs,
and other content libraries remain application-owned; the header is not
included by `mt/mt.hpp`. See
[`docs/integrations/asset-pipeline-contract.md`](docs/integrations/asset-pipeline-contract.md)
for ownership, conversion, diagnostics, and compatibility rules.

Language and external-resource integration is opt-in through
`MT_BUILD_PYTHON` and `MT_BUILD_EXTERNAL_RESOURCES`. Python uses the
installed C++ facade and is disabled by default; select its interpreter with
`MT_PYTHON_EXECUTABLE` (including a Conda interpreter) and optionally provide
`MT_PYTHON_ROOT`, `MT_PYTHON_INCLUDE_DIR`, or `MT_PYTHON_LIBRARY`.
IOSurface import is a separate `MTExternalResources` target and is not
included by `mt/mt.hpp`. See
[`docs/integrations/language-resource-contract.md`](docs/integrations/language-resource-contract.md)
for GIL, ownership, synchronization, format validation, and fallback rules.

SwiftPM support is also provided through `Package.swift`.

The standalone installed-package consumer can be enabled with
`MT_BUILD_INSTALLED_CONSUMER=ON`; it performs a separate
`find_package(mt CONFIG REQUIRED)` configure/build against the installed
package. The repeatable Debug/Release and SwiftPM validation command is
`bash scripts/validate_package.sh`; it must be run on a Metal-capable Mac.
The capability-aware launcher is built as `mt-example-runtime-smoke`; its
entry-point names and fallback decisions are listed in
[`examples/validation-matrix.json`](examples/validation-matrix.json).
Structured evidence belongs under `docs/verification/` and the capability
record template remains in `docs/capability-matrix.md`.

Build and runtime verification are intentionally pending on a Metal-capable
machine. See [`docs/plans/README.md`](docs/plans/README.md) for the staged
implementation and test plan.
