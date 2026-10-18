# Plan 17 — Viewport and picking completion

**Status:** proposed — wrapper-owned viewport follow-up
**Scope:** graphics wrapper editor/viewport behavior; not GUI integration
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 12–16

## Goal

Complete the toolkit-neutral viewport layer so an application can compose
scene, picking, and overlay work without adopting a particular window system,
GUI toolkit, or event loop.

## Deferred work owned by this plan

- GPU drawing for axes, grids, labels, and vertex points.
- Scene traversal and automatic object-ID pipeline generation.
- Multi-attachment picking, depth-value readback, normal readback, and
  compute-distance vertex selection.
- A capability-gated linked-list A-buffer path for overlap-safe object and
  vertex picking, including bounded node capacity and overflow reporting.
- Memoryless/tile and mesh-shader acceleration when the device supports it.
- A stable feature-extension boundary for application-defined viewport
  features, without leaking unsupported Swift closures or C++ subclass ABI.

## Metal-native design

- Picking remains a real render/compute pass with explicit load/store actions,
  attachment formats, synchronization, and readback ownership.
- RGBA8 object IDs remain the baseline portable path. Additional depth,
  normal, tile, memoryless, and mesh outputs are capability-selected.
- The A-buffer path uses fragment atomics, application-visible shared buffers,
  explicit command-buffer lifetime retention, and completion-gated CPU
  traversal. It returns all retained hits for a pixel up to the configured
  node capacity instead of silently reducing overlap to one ID.
- Scene ID generation consumes Plan 16's stable object identity and Plan 15's
  renderer paths; it must not duplicate application scene ownership.
- Toolkit-neutral input remains value-based. AppKit, MTKView, GLFW, Qt, and
  GUI adapters translate native events outside this plan.

## Implementation steps

1. Add concrete GPU feature pipelines for axes, grids, labels, and points
   using explicit phase contracts.
2. Add automatic scene traversal and object-ID pass generation with stable
   object/vertex identity.
3. Add optional depth, normal, and multi-attachment picking targets and
   compute-distance selection.
4. Add a capability-gated linked-list A-buffer for overlap-safe picking with
   explicit node-capacity and overflow behavior.
5. Add capability-gated memoryless/tile/mesh acceleration with a tested
   RGBA8 fallback.
6. Define a constrained extension-registration ABI for features that need
   application-owned pipelines; keep arbitrary callback/subclass bridging
   optional.
7. Add an editor-style offscreen viewport fixture for Plan 18.

## Tests

- Headless tests for phase ordering, feature lifecycle, resize, overlay
  composition, and stable ID encoding.
- Deterministic object, vertex, depth, normal, and distance-picking tests.
- A-buffer overlap, ordering, capacity, overflow, resize, and in-flight
  completion tests.
- In-flight readback and private-to-shared synchronization tests.
- Capability tests for tile/memoryless/mesh paths and baseline fallback.
- C++ API-shape tests proving the viewport has no AppKit, GUI, or window
  dependency.

## Acceptance criteria

- A configured viewport can draw its built-in features and automatically
  generate object-ID passes from a scene.
- Picking returns stable object/vertex identity plus requested depth/normal
  data when supported.
- A-buffer picking returns all retained overlapping hits and reports overflow
  instead of silently dropping them.
- Resize and in-flight work remain safe across all attachment paths.
- Applications can add feature pipelines without requiring a Swift protocol or
  C++ subclass bridge in the core ABI.

## Non-goals

- AppKit/MTKView/GLFW/Qt event loops or GUI widget ownership.
- ImGui, font loading, Python, asset import, or external-resource support.
- Silently substituting a different picking attachment when a native request
  cannot be honored.
