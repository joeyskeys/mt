# `mt` test layout

Tests are grouped by responsibility so later modules can add coverage without
putting all tests in one executable.

```text
tests/
  unit/
    core/          # Error, Result, handles, and ABI-independent value types
    commands/      # Plan 03
    resources/     # Plan 04
    shaders/       # Plan 05
    metal/         # Plan 06; capability-specific tests
    renderer/      # Plan 07
    scene/         # Plan 08
    viewport/      # Plan 09
    host/          # Plan 10; optional adapter API-shape tests
  compile/         # Public-header and API compile-only checks
  consumer/        # External-consumer/package-shape checks
    installed/     # Standalone find_package(mt) consumer project
  integration/     # Cross-module/offscreen tests
  gpu/             # Tests requiring a Metal-capable runtime
```

## Rules

- Unit tests that only exercise C++ value types must not require a Metal
  device.
- Core tests should run in a headless/offscreen mode when they need Metal.
- GPU-family-specific tests belong under `tests/gpu/` or `tests/unit/metal/`
  and must declare their capability requirements.
- Tests must not assume a global `mt::Context`.
- Later modules should add tests in their own subdirectory and register them
  from the nearest `CMakeLists.txt`.
- The external-consumer test should remain small enough to model a real
  downstream C++ project.

The Swift package owns Swift-side unit/runtime tests under
`tests/MTCoreTests`. The CMake test tree covers C++ value types, generated
public-header inclusion, command/surface/frame/resource API shape, shader and
pipeline API shape, renderer API shape, scene/asset API shape, and the
external-consumer shape, and viewport API shape. Swift runtime tests cover
shader library lookup, function constants, parameter blocks, pipeline
creation, renderer lifecycle, scene mutation, geometry upload, material
registration, light storage, viewport lifecycle, and object/vertex picking
when a Metal device is available. Plan 06 tests cover capability records,
argument-buffer encoding, indirect command buffers, and mesh/tile descriptor
validation. Plan 07 tests cover renderer lifecycle, Forward+ configuration,
indexed batch recording, and resize state. Plan 08 tests cover CPU
scene/asset operations plus device-guarded GPU upload and
batch/material/light paths. Plan 09 tests cover phase lifecycle, explicit
overlay passes, RGBA8 ID encoding, resize-safe in-flight readback, and polled
offscreen readback. Optional Plan 10 targets add C++ API-shape tests for
AppKit and MTKView adapters. Remaining directories are documented extension
points and do not need placeholder files until their modules are implemented.
Plan 11 validation tests cover runtime capability relationships, invalid
descriptor rejection, and shutdown failure paths. Plan 12
`CoreLifetimeTests.swift` covers subresource validation, explicit private
staging/readback, completion tokens, retirement, versioned slots, and the
optional registry. The installed consumer test is opt-in because it performs a
package install and a second configure/build.
Plan 13 shader tests cover deterministic specialization/layout signatures,
reflection mismatch and extra-binding rejection, argument-table value types,
native linked-function descriptor composition, requested compute threadgroup
limits, and mesh/object MSL host-layout assertions. Runtime archive, dynamic
library, argument-buffer-tier, and cache reuse tests remain device-gated for
the Metal-capable verification machine. Plan 14 tests cover capability
availability provenance, explicit unknown limits, memoryless/imageblock and
tile descriptors, ray-tracing descriptor validation, motion geometry shape,
counter-resolution values, SIMD-group records, and the no-silent-fallback
diagnostic path. Runtime ray-tracing, counter, tile, and memoryless checks
remain device-gated for the Metal-capable verification machine.
Plan 15 tests cover pass scheduling, transparent ordering, deterministic
Forward+ cluster bounds and overflow, CPU culling/LOD selection, persistent
statistics, native-path selection records, and meshlet staging constraints.

