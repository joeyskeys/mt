# Plan 14 — Metal-native capabilities completion

**Status:** proposed — wrapper-owned Metal extension follow-up
**Scope:** graphics wrapper native capabilities; not a host integration
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 02–06, 12, and 13

## Goal

Finish the capability-gated APIs for features that are specific to Metal or
specific Apple GPU families. These features remain part of the wrapper even
when optional at runtime. The API must expose the native path, report limits
accurately, and provide an explicit fallback or unsupported result.

## Deferred work owned by this plan

- Tile pipeline, imageblock, tile-local storage, and memoryless attachment
  descriptors and encoding.
- Ray-tracing acceleration-structure build/update descriptors, intersection
  function tables, ray dispatch, and motion support.
- Counter sample buffers and timestamp/counter collection beyond the current
  command-buffer timing hooks.
- SIMD-group, matrix, mesh payload, mesh output, and tile imageblock limits
  where the deployment SDK exposes them.
- Device-family and SDK availability records for every native extension.
- Capability-specific fallback/error records that distinguish unavailable,
  unsupported, invalid, and not-yet-measured states.

## Metal-native design

- The wrapper must not flatten mesh, tile, ray-tracing, or counter APIs into a
  generic baseline interface that hides their constraints.
- Availability checks must account for OS, SDK, device family, feature tier,
  function availability, and descriptor limits.
- An unknown limit is not a valid zero limit. The capability record must
  distinguish `unknown`, `unsupported`, and a measured zero-sized limit.
- Native resources and encoders remain owned by the device/command-buffer
  graph. No global context or hidden synchronization queue is introduced.
- Fallback renderers are selected by higher-level renderer plans and must be
  observable; requesting a native-only operation must not silently become an
  unrelated indexed or CPU path.

## Implementation steps

1. Expand capability records with availability provenance and optional limit
   values.
2. Add tile/imageblock/memoryless descriptors, validation, and encoder hooks.
3. Add ray-tracing resource/build/table/dispatch wrappers with explicit
   lifetime and synchronization rules.
4. Add counter sample-buffer and timestamp collection APIs that can be polled
   through the supported C++ interop contract.
5. Add device-family validation for mesh payload/output and tile limits.
6. Connect native capability errors and fallback records to renderer,
   viewport, and validation layers.

## Tests

- Unit/API-shape tests for all descriptor and capability value types.
- Device-guarded tests for tile, memoryless, ray-tracing, counter, mesh, and
  SIMD/matrix paths.
- Negative tests for unsupported devices, unavailable SDK symbols, invalid
  limits, incompatible storage modes, and invalid encoder state.
- Tests that verify native requests never silently select a baseline path.
- Capability-matrix entries recording device family, OS, SDK, and observed
  limits.

## Acceptance criteria

- Each native capability has a query, validated creation/encoding path,
  actionable unsupported error, and documented fallback where meaningful.
- Ray-tracing, tile, and counter resources remain explicit in the C++ API.
- Unknown SDK/device limits are represented without being mistaken for zero.
- Higher-level modules can select native and fallback paths from one
  capability record without inventing Vulkan terminology.

## Non-goals

- Making every device support every Metal feature.
- Adding host window, GUI, font, Python, importer, or external-memory APIs.
- Removing native feature APIs to preserve portability to non-Metal platforms.
