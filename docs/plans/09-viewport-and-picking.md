# Plan 09 — Viewport features and picking

**Status:** implemented — Swift-first viewport/picking slice; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md), [Plan 03](03-commands-surfaces-and-frames.md), [Plan 04](04-resources-memory-and-sync.md), [Plan 07](07-renderer-layer.md), [Plan 08](08-scene-assets-and-built-in-shaders.md)

## Goal

Port vkkk's composable viewport behavior without coupling it to a window,
global context, or one renderer.

The viewport is an orchestration layer over `Device`, resources, a renderer,
and application-owned frame/command-buffer objects.

## Responsibilities

- Feature composition.
- Attach/resize/update/record lifecycle.
- Picking, scene, and screen-overlay phases.
- Axes and grid features.
- Object and vertex picking.
- Offscreen ID/depth targets and readback.
- Overlay load/store behavior.

## Non-goals

- Owning `CAMetalLayer` or AppKit input.
- Owning the device or command queue.
- Reimplementing the renderer.
- Assuming Vulkan subpasses or barriers.
- Adding all editor UI controls to the core.

## Feature model

The conceptual feature contract has explicit attach, resize, update, and
record hooks. Because the public ABI is generated from Swift, the first
implementation uses configured type-erased feature objects rather than a
Swift protocol or C++ virtual-subclass bridge:

```cpp
class ViewportFeature {
public:
    ViewportFeature(
        std::string name,
        ViewportFeatureKind kind,
        ViewportPhase phase,
        bool enabled);
    bool is_attached() const;
    uint32_t resize_count() const;
    uint32_t update_count() const;
    uint32_t record_count() const;
};
```

The important behavior is that feature ownership and lifecycle are explicit.
A future callback/subclass ABI can be added without making it a requirement
for the core viewport.

## Phases

The default phase order is:

```text
Picking → Scene → ScreenOverlay
```

Each phase declares:

- target attachments;
- load/store actions;
- depth/stencil policy;
- resource dependencies;
- whether it can run when picking or overlays are disabled.

The viewport should use separate Metal encoders/render passes where required.
It must not fake nested Vulkan subpasses.

## Viewport context

`ViewportContext` is an operation-scoped view, not a global Metal context. It
may contain references to:

- `Device`;
- current `Surface` or offscreen target;
- renderer;
- scene and drawable manager;
- frame index;
- camera;
- capability data;
- feature-local resource registry.

It must not own command queues, global resources, or the host event loop.

## Axis and grid features

Implement:

- camera reference;
- visibility flag;
- coordinate-system labels;
- font/text resource references;
- grid cell count and cell size;
- depth/overlay behavior;
- resize handling.

Use ordinary render passes first. Add tile or mesh-shader acceleration only
when it simplifies a real path and the capability is present.

## Object picking

Provide:

- stable object IDs for the pick pass;
- optional color/depth ID target;
- coordinate-to-pixel mapping;
- asynchronous readback;
- callback or polled result;
- disabled/overflow state.

The ID format must be chosen based on Metal render-target support and the
application's object-count limits. It must not assume a Vulkan image format is
available.

## Vertex picking

Provide:

- point-list or vertex-buffer input;
- object transform;
- point size/visibility settings;
- vertex IDs and owning object IDs;
- pick callback/polled result;
- overflow reporting.

Potential implementations:

- rasterized point IDs;
- compute distance/reduction;
- mesh-shader point expansion on supported devices.

The implementation should select one explicitly and document precision and
depth behavior.

## Offscreen targets and readback

Picking targets are owned by the viewport or a feature-local resource owner:

- recreate on resize;
- keep alive while readback is in flight;
- use memoryless attachments only when no readback is needed;
- use stored textures for asynchronous CPU results;
- avoid synchronously blocking the render thread unless requested.

Readback must be scheduled through a blit/command-buffer completion path from
Plan 03 and Plan 04.

## Renderer integration

The viewport should:

1. update feature state;
2. ask the renderer to record the scene phase;
3. record feature-specific picking and overlays;
4. preserve color/depth using explicit load/store actions;
5. return pick results independently of renderer implementation.

Renderer and viewport must share resource and camera contracts but neither
should own the other.

## Implementation steps

1. Define phase, feature, and viewport operation types.
2. Implement a no-op feature and lifecycle tests.
3. Add offscreen viewport targets and resize handling.
4. Add grid and axes features.
5. Add object ID picking and async readback.
6. Add vertex picking and overflow reporting.
7. Integrate Forward renderer scene and overlay passes.
8. Add mesh/tile acceleration paths where justified.
9. Add an editor-style example.

## Acceptance criteria

- Features can attach, resize, update, and record without a global context.
- Picking, scene, and overlay phases have explicit pass boundaries.
- Object picking returns stable IDs through a tested Metal readback path.
- Vertex picking documents precision, depth, and overflow behavior.
- Resize and in-flight readback lifetimes are safe.
- The viewport can use an offscreen target and a window surface independently.
- An application can add or remove optional features without modifying core
  command or device ownership.

## Implementation in this slice

The Swift core now provides a type-erased, C++-interop-friendly viewport
orchestration layer in `Sources/MTCore/Viewport.swift`. It intentionally does
not expose a Swift protocol or require C++ subclasses. `ViewportFeature` is a
configured feature object with explicit `ViewportPhase` and
`ViewportFeatureKind` values, attach/resize/update/record counters, and axes,
grid, object-picking, vertex-picking, and no-op factories.

The public C++ facade is split into:

- `mt/viewport.hpp`: viewport state, phases, features, camera/update data, and
  the `Viewport` coordinator;
- `mt/picking.hpp`: `PickingID`, pick requests, and polled pick results.

`Viewport` retains a device reference but does not create or own a command
queue, surface, renderer, or event loop. A renderer can be attached
explicitly. Scene recording delegates to the existing `Renderer`; overlay
recording opens a separate render encoder with `.load`/`.store` actions so
Metal pass boundaries remain visible.

Picking uses a Metal-native format choice rather than assuming a Vulkan
integer attachment:

- IDs are encoded into all four channels of `.rgba8Unorm`, giving a stable
  32-bit value with zero reserved for “no hit”;
- the viewport owns a private render color target, a shared CPU-visible
  readback texture, and a private depth target, recreating them on resize;
- scheduling a readback encodes an explicit Metal blit from the private ID
  target to the shared texture;
- applications encode object or vertex IDs with their own picking pipeline,
  call `makePickingRenderPass`, then schedule a `CommandBuffer` for polling;
- `pollPickResult` reads the retained pre-resize texture only after the
  command buffer reaches `.completed`, so a resize does not invalidate an
  in-flight readback;
- vertex requests carry the owning object ID and encode vertex `n` as `n + 1`,
  making `UInt32.max` an explicit overflow case.

`tests/unit/viewport` covers the generated C++ API shape. `ViewportTests.swift`
covers ID encoding, feature lifecycle, stable object registration, explicit
overlay passes, clear readback, and device-guarded object/vertex ID
readback.

## Intentionally deferred

- GPU drawing implementations for axes, grids, labels, and vertex points;
  the feature objects currently provide lifecycle/configuration contracts and
  explicit phase hooks while applications supply their pipelines. Completion
  belongs to
  [Plan 17 — Viewport and picking completion](17-viewport-and-picking-completion.md).
- A user-defined Swift protocol or C++ subclass bridge for arbitrary feature
  callbacks; this will require a deliberate ABI design rather than leaking
  Swift closures into C++. The constrained extension boundary is part of Plan
  17, while completion notification ABI belongs to Plan 12.
- Scene traversal and automatic ID-pipeline generation from `Scene` and
  `DrawableManager` belong to Plan 17 and consume Plan 16 scene identities.
- Multi-attachment object/depth/normal picking, depth-value readback, and
  compute-distance vertex selection belong to Plan 17.
- Callback-based completion; polling is the supported cross-language contract
  until the ABI work in
  [Plan 12 — Core ABI, resources, and lifetime completion](12-core-abi-resources-and-lifetime.md)
  is complete.
- Memoryless picking attachments, tile/mesh-shader acceleration, and an
  editor-style viewport example belong to Plan 17 and Plan 18 respectively.

Build, C++ ABI generation, shader compilation, and runtime verification remain
pending on a Metal-capable macOS machine; viewport evidence is tracked in
[Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).

