# Plan 11 — Validation, examples, and external-consumer verification

**Status:** in progress — validation harness and consumer slice; runtime verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** baseline slices of Plans 01–10

## Goal

Verify that `mt` is a usable Swift-first Metal library with a generated C++
interface across device capabilities, execution modes, and host integrations.

This plan is cross-cutting. It should be started with the first core module,
not postponed until the renderer is complete.

## Test layers

### 1. Public-header tests

Compile:

- each public header alone where practical;
- an aggregate include;
- C++20 consumer code;
- Swift module and generated Swift C++ header;
- Debug and Release configurations.

Check that core C++ consumers do not require Swift source, AppKit, MetalKit,
or optional third-party libraries, while still linking the packaged Swift
runtime/library.

### 2. Package-consumer test

Build a separate project against an installed package:

```cmake
find_package(mt CONFIG REQUIRED)
target_link_libraries(consumer PRIVATE mt::mt)
```

The consumer should:

- enumerate devices;
- create a queue and command buffer;
- render offscreen;
- read back a known result;
- use only installed headers and exported targets.

This test is the minimum proof that the project is a library rather than an
application-specific Xcode project.

### 3. Offscreen rendering tests

Add deterministic tests for:

- clear and store;
- indexed and instanced geometry;
- depth/stencil;
- blending;
- texture sampling;
- MSAA and resolve;
- compute-to-buffer;
- compute-to-texture;
- blit copies and mip generation;
- readback;
- object and vertex picking.

Tests should compare structured results or tolerances rather than screenshots
alone.

### 4. Command and lifetime tests

Cover:

- encoder state transitions;
- ending encoders before commit;
- command-buffer completion;
- command-buffer error reporting;
- resource retention while work is in flight;
- drawable unavailable;
- resize during in-flight work;
- queue/device destruction order;
- cross-queue synchronization where implemented.

### 5. Shader and pipeline tests

Validate:

- metallib loading;
- missing function diagnostics;
- binding index/type mismatch;
- function constants;
- vertex/fragment pipelines;
- compute pipelines;
- mesh/object pipelines;
- attachment/sample-count validation;
- pipeline cache invalidation.

Every built-in MSL/C++ layout pair needs a size/alignment test.

## Capability matrix

Record actual results for available machines and SDKs:

| Capability | Minimum path | Native path | Test |
| --- | --- | --- | --- |
| Basic Metal | buffers/textures/render/compute | all devices | offscreen triangle |
| Mesh shaders | indexed fallback | object/mesh pipeline | planned mesh triangle |
| Argument buffers | direct slots | argument tables | material table |
| ICB | indirect draws | GPU-generated commands | culling example |
| Tile/memoryless | stored render pass | tile-local pass | bandwidth example |
| Ray tracing | unavailable/omitted | acceleration structures | optional ray test |
| Managed storage | explicit sync | direct shared/private path | upload/readback |

The matrix should identify macOS version, SDK, device family, and why a
capability is unavailable. Do not infer support from CPU architecture alone.

## Examples

Build examples in increasing order:

1. `device_info` — enumerate devices and print capabilities.
2. `offscreen_triangle` — create device/queue/command buffer and read back.
3. `window_triangle` — AppKit/`CAMetalLayer` presentation.
4. `indexed_mesh` — buffers, textures, depth, and pipeline bindings.
5. `compute_image` — compute and blit path.
6. `mesh_triangle` — planned object/mesh/fragment shader.
7. `argument_buffer_materials` — typed resource tables.
8. `gpu_culling` — indirect/ICB path.
9. `tile_pass` — tile/memoryless path where supported.
10. `forward_plus` — clustered lights.
11. `viewport_picking` — scene, overlays, and readback.

Every example should state required capabilities and its fallback behavior.

## Debug and profiling checks

- Run with Metal API validation enabled.
- Add labels to devices, queues, command buffers, resources, pipelines, and
  passes.
- Capture representative frames in Xcode GPU tools.
- Use GPU counters where available.
- Check for resource warnings, synchronization errors, and shader diagnostics.
- Keep debug labels useful in release profiling builds where possible.

## Failure-path requirements

Test and document:

- no Metal device;
- unsupported mesh/tile/ray feature;
- no drawable;
- allocation/heap failure;
- invalid storage mode;
- incompatible texture format;
- shader compilation error;
- pipeline reflection mismatch;
- command-buffer execution error;
- readback requested from a non-stored target.

Failures should be actionable and should not leave partially initialized
renderer or viewport state.

## Performance checks

Measure only after correctness:

- CPU time spent encoding;
- command-buffer count;
- resource upload bandwidth;
- pipeline creation and cache hit rate;
- draw/dispatch count;
- argument-buffer versus direct-slot cost;
- CPU versus GPU culling;
- memoryless/tile bandwidth impact;
- mesh-shader versus indexed fallback.

Record device and build configuration with measurements.

## Implementation steps

1. Add header and external-consumer tests with Plan 01.
2. Add offscreen smoke tests with Plans 02–04.
3. Add shader/pipeline tests with Plan 05.
4. Add capability-specific tests with Plan 06.
5. Add renderer, scene, and viewport examples as those modules land.
6. Add optional integration tests independently.
7. Record a device/SDK capability matrix.
8. Add Debug/Release and package-install verification to CI or local scripts.

## Acceptance criteria

- An external C++ project can build and run an offscreen example from the
  installed package.
- Core behavior is tested without a window.
- Native Metal features have capability-specific tests and documented
  fallbacks.
- Shader/resource layout mismatches fail before GPU submission.
- Lifetime, resize, drawable-loss, and command errors are covered.
- Examples show both the direct Metal-style API and optional higher-level
  renderer/viewport APIs.

## Implementation in this slice

The repository now has the first validation harness:

- existing C++ public-header and module API-shape tests cover the generated
  C++ facade through Plans 01–10;
- `ValidationTests.swift` covers device enumeration, runtime capability
  relationships, invalid descriptor rejection, and actionable shutdown
  failures;
- `tests/consumer/installed` is a standalone `find_package(mt CONFIG REQUIRED)`
  consumer;
- `tests/consumer/run_installed_consumer.cmake` can install the current build,
  configure/build the standalone consumer, and run it;
- `MT_BUILD_INSTALLED_CONSUMER` exposes that package check as an opt-in CTest
  entry;
- `examples/consumer_smoke` and `examples/README.md` establish the external
  consumer/example boundary and capability requirements.

The installed-consumer flow is opt-in because it performs an install and a
second configure/build. It is deliberately not run as part of the default
core test tree.

## Intentionally deferred

- Deterministic offscreen triangle, texture, compute-image, MSAA, depth,
  blending, and full renderer example executables.
- Windowed AppKit/MTKView examples and GUI/font/Python examples.
- Runtime mesh-shader, argument-buffer, ICB, tile, ray-tracing, and
  Forward+ capability matrix results.
- CI jobs for Debug/Release, package installation, Metal API validation,
  Xcode GPU capture, and multiple device families.
- Performance measurements and persistent result storage.

Those checks require a Metal-capable verification machine and should be added
as consumers of the current installed package rather than weakening the
core/offscreen dependency boundary. They are owned by
[Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).
Windowed examples are verified through Plan 18 but implemented as optional
host consumers in
[Plan 19 — Native host integrations](19-native-host-integrations.md).

Build, package installation, shader compilation, and runtime verification
remain pending on a suitable macOS machine. Plan 18 is verification work; it
does not make the deferred renderer, scene, viewport, or Metal-native
features complete.

