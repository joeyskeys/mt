# Plan 18 — Validation, examples, and release evidence

**Status:** proposed — verification and release track
**Scope:** proves wrapper behavior; adds no graphics feature and no integration
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 01–17 and Plan 11's initial validation harness

## Goal

Turn the current compile-time/API-shape checks into evidence that the Swift
Metal wrapper works as an installed library on real Metal-capable machines.
This plan records verification; it must not be used to hide missing wrapper
features or to introduce host dependencies into the core target.

## Work owned by this plan

- Upgrade the installed C++ consumer from version/type checks to device
  enumeration, queue/command-buffer creation, deterministic offscreen
  rendering, and known-result readback.
- Add deterministic offscreen coverage for clear/store, indexed and instanced
  geometry, depth/stencil, blending, texture sampling, MSAA/resolve, compute,
  blits/mip generation, and picking.
- Cover encoder state, completion/error reporting, in-flight resource
  retention, drawable loss, resize during work, destruction order, and
  cross-queue synchronization.
- Validate metallib loading, missing functions, function constants, binding
  mismatches, reflection, C++/MSL size/alignment, formats, sample counts, and
  threadgroup limits.
- Exercise mesh, argument-buffer, ICB, tile/memoryless, ray-tracing, counter,
  managed-storage, and fallback paths where the device supports them.
- Populate the capability matrix with macOS, SDK, device family, registry
  identity, feature result, fallback, diagnostics, and test evidence.
- Add Debug/Release package checks, Metal API validation, Xcode GPU captures,
  multi-device-family runs, CI jobs, performance records, and persistent
  result storage.
- Add the runtime examples listed by Plan 11:
  `device_info`, `offscreen_triangle`, `window_triangle`, `indexed_mesh`,
  `compute_image`, `mesh_triangle`, `argument_buffer_materials`,
  `gpu_culling`, `tile_pass`, `forward_plus`, and `viewport_picking`.

## Verification design

- Core tests run headless/offscreen and do not require AppKit, GUI, Python,
  importers, or external-resource frameworks.
- Every capability-specific example states its required capability and
  fallback behavior.
- Results are structured values or tolerances where possible, not screenshots
  alone.
- Runtime records distinguish an untested capability from an unsupported
  capability. CPU architecture is never used as a proxy for Metal support.
- Installed-consumer tests use only exported targets and installed headers;
  source-tree includes are not accepted as proof of packaging.

## Implementation steps

1. Define the verification machine matrix and result-record format.
2. Extend the standalone consumer and add deterministic offscreen fixtures.
3. Add the command, lifetime, shader, renderer, scene, and viewport suites.
4. Add capability-specific tests and fallback assertions.
5. Add package-install, generated-header, Debug/Release, and SwiftPM checks.
6. Run Metal API validation and GPU captures on representative devices.
7. Store results and performance measurements with commit, SDK, device, and
   configuration metadata.

## Tests and artifacts

- C++ installed-package consumer executable and CMake/SwiftPM package checks.
- Swift runtime suites and C++ API-shape suites for every wrapper module.
- `docs/capability-matrix.md` populated with reproducible verification
  records.
- Example output and structured readback fixtures.
- CI logs, Metal validation diagnostics, GPU captures, and performance
  records.

## Acceptance criteria

- A fresh external C++ project can install, link, render offscreen, and read
  back a known result using only the packaged library.
- Core, renderer, scene, viewport, and native-feature behavior has repeatable
  runtime evidence on at least one Metal-capable machine.
- Unsupported capabilities produce documented fallback/error results.
- Debug/Release and generated-header/package checks are reproducible.

## Non-goals

- Implementing missing renderer, resource, shader, or native capability code;
  those belong to Plans 12–17.
- Adding AppKit, GUI, font, Python, importer, or external-resource features;
  those belong to Plans 19–22.
- Treating a successful compile as proof of GPU correctness.
