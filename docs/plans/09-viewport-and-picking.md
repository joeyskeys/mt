# Plan 09 — Viewport features and picking

**Status:** proposed
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

Support a feature interface with explicit dependencies:

```cpp
class ViewportFeature {
public:
    virtual ~ViewportFeature() = default;
    virtual Result<void> on_attach(ViewportContext&) = 0;
    virtual Result<void> on_resize(Extent) = 0;
    virtual void on_update(const ViewportUpdate&) = 0;
    virtual Result<void> on_record(CommandBuffer&, ViewportPhase) = 0;
};
```

The exact implementation may use templates like vkkk's
`Viewport<FeatureTypes...>` or type-erased features. The important behavior is
that feature ownership and lifecycle are explicit.

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

