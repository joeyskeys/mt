# Plan 13 — Shaders, pipelines, and bindings completion

**Status:** implemented — Swift-first; verification pending on a Metal-capable machine
**Scope:** graphics wrapper shader and pipeline layer; not an integration
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 05 and 12

## Goal

Complete the Metal-native shader and pipeline layer so applications can ship
stable metallibs, validate resource layouts before submission, and use
argument-buffer and specialized-pipeline features without a Vulkan descriptor
set emulation layer.

## Deferred work owned by this plan

- In-memory and persistent render/compute pipeline caches with device, SDK,
  shader, and descriptor invalidation.
- Metal binary archive creation, loading, and invalidation.
- Dynamic-library composition where available, with a capability-gated
  fallback.
- Depth/stencil state objects beyond attachment-format validation.
- Full argument-buffer layout and value encoding, including nested values,
  resource arrays, and persistent material/resource tables.
- Reflection validation for binding index, resource type, buffer layout,
  alignment, attachment formats, sample counts, and threadgroup limits.
- A built-in mesh/object/fragment MSL fixture and its C++/MSL layout tests.

## Metal-native design

- MSL and metallib remain the source of truth for Metal function behavior.
  The wrapper records entry points, constants, layouts, and reflection rather
  than translating GLSL or SPIR-V as a required path.
- Argument buffers are exposed as Metal argument tables. They are not renamed
  descriptor sets and must preserve Metal array, tier, and resource-index
  constraints.
- Pipeline caches are keyed by the complete Metal-relevant input, including
  device identity, SDK/compiler information, function constants, attachment
  formats, sample count, and binding layout.
- Unsupported dynamic libraries, binary archives, mesh functions, or argument
  buffer tiers produce capability-specific diagnostics.

## Implementation steps

1. Define cache keys, cache ownership, invalidation, serialization, and
   failure recovery without making caches global process state.
2. Add depth/stencil descriptors and pipeline state creation with early
   attachment/sample validation.
3. Complete reflected binding layouts and argument-buffer value encoding,
   including nested and array values.
4. Add binary archive and dynamic-library wrappers behind availability checks.
5. Add the mesh/object/fragment shader fixture and verify its C++/MSL
   structure.
6. Integrate validation into pipeline creation so mismatches fail before
   command encoding.

## Tests

- Swift tests for missing functions, function constants, reflection mismatch,
  cache hits/misses, invalidation, depth/stencil descriptors, argument arrays,
  nested values, and unsupported capability errors.
- C++ API-shape tests for cache, binding, archive, and depth/stencil types.
- Layout tests that compare C++ sizes/alignment with the matching MSL structs.
- Capability-specific tests for argument-buffer tiers, dynamic libraries,
  binary archives, and mesh functions.

## Acceptance criteria

- A pipeline request with an invalid binding, layout, attachment, or sample
  configuration fails before GPU submission.
- A valid argument-buffer table can encode nested resources and arrays without
  exposing Metal Objective-C types to C++.
- Cache reuse and invalidation are deterministic and device-specific.
- The built-in mesh/object shader fixture can be packaged and selected only
  when the device supports it.

## Non-goals

- GUI, font, Python, asset-import, or external-resource integration.
- A required GLSL/SPIR-V translation path.
- Replacing Metal argument buffers with a lowest-common-denominator binding
  abstraction.

## Implementation notes

- `MTCore` now exposes device-scoped render/compute pipeline caches. Cache
  keys include the device registry ID, runtime SDK token, shader/function
  specialization signatures, binding-layout signature, and descriptor inputs.
  A cache can optionally attach a device-matched `MTLBinaryArchive` for
  persistent pipeline-function reuse.
- Binary archives, dynamic libraries, linked functions, and depth/stencil
  states remain direct Metal concepts. Unsupported dynamic-library and
  argument-buffer-tier requests return capability-specific diagnostics.
- Argument buffers support resource arrays, tier-2 nested encoders, and
  inline constant values, persistent wrapper tables, and resource arrays
  without introducing descriptor-set semantics.
- Reflection validation rejects missing, extra, or incompatible bindings and
  checks reflected data-size and alignment requirements.
- The mesh/object fixture and host-side layout assertions are present, but
  shader compilation and all runtime/device tests remain intentionally
  unverified on the current Intel development machine.
