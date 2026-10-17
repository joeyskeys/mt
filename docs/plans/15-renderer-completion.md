# Plan 15 — Renderer completion

**Status:** proposed — wrapper-owned renderer follow-up
**Scope:** graphics wrapper renderer layer; not a host or GUI integration
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 12–14 and 16, with Plans 13 and 14 required for
native paths

## Goal

Turn the current renderer submission layer into a reusable Metal-native
Forward/Forward+ renderer while keeping device, queue, surface, and frame-loop
ownership with the consuming application.

The renderer should provide useful policy and scheduling, but it must not
replace the lower-level Metal object graph with a mandatory global context.

## Deferred work owned by this plan

- GPU light-cluster preparation and consumption for Forward+.
- Depth prepass, shadow passes, transparent sorting, and overlay scheduling.
- Lines, points, billboards, and other non-triangle batch paths.
- Material and argument-buffer table integration.
- Pipeline-cache integration and invalidation handling.
- GPU culling and LOD generation.
- Meshlet upload and native mesh/object-shader submission.
- Capability-aware native-path fallback renderers.
- Persistent renderer statistics and GPU counter integration.

## Metal-native design

- A renderer chooses among indexed, indirect, mesh/object, compute, and tile
  paths based on the requested policy and `DeviceCapabilities`.
- Forward+ clustering uses Metal compute and explicit light/index buffers; it
  is not represented as a fake Vulkan descriptor or render-pass abstraction.
- The renderer records work into application-provided command buffers and does
  not own the command queue, surface, drawable, or event loop.
- Resource retirement and pipeline cache lifetime follow Plans 12 and 13.
- A requested native feature produces an observable selected path and fallback
  reason. Fallback is allowed only when it preserves the requested rendering
  semantics.

## Implementation steps

1. Define render-pass and batch scheduling boundaries for depth, shadow,
   opaque, transparent, overlay, and presentation phases.
2. Add compute light-cluster preparation and bind its results through the
   completed material/binding layer.
3. Add depth, shadow, transparent, line, point, billboard, and overlay paths.
4. Add GPU culling/LOD buffers and meshlet upload/submission management.
5. Integrate pipeline caches, material tables, native capability records, and
   fallback diagnostics.
6. Persist CPU/GPU submission statistics without retaining transient resources.

## Tests

- Headless deterministic tests for each render-pass ordering and batch type.
- Forward+ cluster bounds, light-index, overflow, and empty-scene tests.
- Depth, shadow, blending, transparent-order, line, point, and billboard
  result tests.
- Capability-gated mesh, indirect, tile, and GPU-culling tests with fallback
  assertions.
- In-flight resize, resource retirement, pipeline invalidation, and renderer
  shutdown tests.
- C++ API-shape tests that prove the renderer does not require a window or
  global context.

## Acceptance criteria

- Forward and Forward+ renderers can submit a complete scene through an
  application-owned command buffer.
- Pass ordering, selected native path, fallback reason, and statistics are
  observable.
- GPU culling, meshlet, and argument-buffer paths are capability-gated and
  preserve a tested indexed fallback.
- Renderer shutdown and resize do not release resources still used by Metal.

## Non-goals

- AppKit, `MTKView`, GLFW, Qt, ImGui, font, Python, or external-resource
  ownership.
- An application-owned window/event loop inside the renderer.
- A Vulkan-compatible render graph that hides Metal pass behavior.
