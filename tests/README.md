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
public-header inclusion, command/surface/frame/resource API shape, and the
external-consumer shape. Remaining
directories are documented extension points and do not need placeholder files
until their modules are implemented.

