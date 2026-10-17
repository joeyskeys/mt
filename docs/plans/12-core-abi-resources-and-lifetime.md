# Plan 12 — Core ABI, resources, and lifetime completion

**Status:** implemented — Swift-first core completion; verification pending
**Scope:** graphics wrapper core; not a host or GUI integration
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 01–04 and the verified decisions from Plan 11

## Goal

Finish the low-level `mt` contract that every higher-level renderer and
consumer depends on. This plan covers the Swift/C++ package boundary, Metal
resource transfer, command completion, and lifetime rules. It does not add
AppKit, `MTKView`, GLFW, Qt, ImGui, Python, or file-format dependencies.

The result should let an external C++ application safely use private and
managed resources, read back subresources, retain work in flight, and consume
one stable package contract across supported Swift toolchains.

## Scope implemented by this plan

- Resolve the Plan 01 distribution decisions:
  - library naming and versioning;
  - canonical CMake and SwiftPM consumption paths;
  - Swift compiler/SDK ABI compatibility policy;
  - source MSL versus packaged metallib responsibilities.
- Add drawable readback and complete buffer/texture subresource-region
  operations.
- Add explicit private-resource staging uploads and readbacks.
- Complete managed-resource synchronization and storage-mode-specific
  ownership rules.
- Add completion-aware ring-buffer reuse and resource retirement.
- Add version tracking for replaced or removed GPU resources.
- Define an interop-safe completion notification contract. Polling is the
  supported baseline; callbacks remain outside the core ABI until a supported
  shape is selected.
- Keep the string-keyed registry optional and separate from typed resource
  ownership.

## Metal-native design

- Staging is explicit. A private resource is populated or read through a
  declared staging resource and blit/command-buffer synchronization; the core
  must not hide an extra queue or silently change storage mode.
- Resource retirement follows command-buffer completion, not CPU scope exit.
  The API must retain the native resource until all submitted work that uses
  it has completed.
- Managed storage synchronization is exposed as an explicit operation with
  clear direction and ownership. Shared, managed, private, and memoryless
  paths must not be presented as interchangeable.
- The C++ ABI exposes stable value descriptors and opaque/reference wrappers,
  not compiler-specific Metal or Objective-C ownership types.

## Implementation steps

1. Record the package name, versioning, supported Swift/SDK range, and
   CMake/SwiftPM responsibilities in the parent API documentation.
2. Extend buffer and texture APIs with validated subresource regions,
   mip/array selection, staging resources, and readback result ownership.
3. Implement explicit private and managed transfer paths and report
   unsupported combinations as structured errors.
4. Add completion-backed allocation and retirement primitives for ring
   buffers, replaced meshes, and transient staging resources.
5. Define the polling and optional callback boundary for C++ consumers.
6. Add the optional registry only after typed lifetime behavior is complete;
   make its ownership and thread-safety rules explicit.

## Tests

- Swift tests for every storage mode, transfer direction, subresource region,
  mip/array selection, synchronization failure, and resource retirement case.
- C++ generated-header and installed-package tests for descriptors, readback
  result values, completion polling, and ownership shape.
- Capability-gated tests for managed/private paths and a no-device path that
  returns actionable errors.
- In-flight replacement/destruction tests that verify resources remain valid
  until command completion.

## Implementation in this slice

- Recorded the current package contract in `README.md`: the CMake package is
  the canonical installed C++ path, SwiftPM is the Swift path, the exported
  target is `mt::mt`, and the generated header is compiler/SDK-specific.
- Added `BufferRange`, `TextureRegion`, and
  `TextureTransferDescriptor` value types with extent, pitch, mip, slice, and
  byte-count validation.
- Added CPU-visible subresource upload/readback and explicit blit
  buffer-to-texture, texture-to-buffer, drawable-to-buffer, and
  texture-region copy operations.
- Added explicit staging-buffer creation and storage-mode status properties.
- Added managed synchronization direction APIs and actionable device/blit
  error descriptions for invalid transfer/resource requests.
- Added command completion state, polling tokens, explicit resource retention,
  completion-aware dynamic-buffer reset/sealing, retirement queues, versioned
  buffer/texture slots, and an optional typed resource registry.
- Added Swift runtime tests, C++ API-shape coverage, and installed-consumer
  shape checks for the new core contract.

The completion callback ABI remains intentionally polling-based. A future
callback surface must be designed separately without exposing Swift closures
or borrowed Metal objects through the generated C++ header.

## Acceptance criteria

- A C++ consumer can upload, render from, and read back a private texture or
  buffer through explicit staging.
- Subresource transfers reject invalid ranges before GPU submission.
- Managed synchronization direction is observable and testable.
- Retired resources are not released while referenced by submitted work.
- The generated C++ API has a documented compatibility policy and does not
  require application code to import Swift or Objective-C headers.

## Non-goals

- Renderer policy, scene traversal, material tables, or viewport behavior.
- AppKit, `MTKView`, GLFW, Qt, GUI, font, Python, importer, or external-memory
  adapters.
- Hiding Metal storage modes behind a Vulkan-style universal allocation layer.
