# Plan 07 — Renderer layer

**Status:** implemented — Swift-first renderer slice; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** [Plan 03](03-commands-surfaces-and-frames.md), [Plan 04](04-resources-memory-and-sync.md), [Plan 05](05-shaders-pipelines-and-bindings.md), [Plan 06](06-metal-native-features.md)

## Goal

Provide reusable rendering strategies above the low-level Metal wrapper while
keeping device, queue, surface, and application lifecycle ownership explicit.

The renderer layer should carry over the useful vkkk Forward and Forward+
behavior, but it must submit through Metal command buffers and use Metal-native
binding and GPU-driven paths where they improve the result.

## Responsibilities

- Common renderer lifecycle.
- Pipeline/material registration.
- Opaque and transparent batching.
- Camera and light data synchronization.
- Shadow passes.
- Forward rendering.
- Forward+ clustered-light preparation.
- Mesh-shader and indirect submission paths.
- Resize-dependent target management.

## Non-goals

- Owning the window or event loop.
- Replacing `Device` or `CommandQueue`.
- A mandatory global resource registry.
- Implementing scene import; Plan 08 owns that.
- Implementing viewport feature composition; Plan 09 owns that.

## Renderer contract

Illustrative interface:

```cpp
class Renderer {
public:
    virtual ~Renderer() = default;

    virtual Result<void> initialize(Device&) = 0;
    virtual void shutdown() = 0;
    virtual void update() {}
    virtual Result<void> record_commands(
        CommandBuffer&, const RenderView&) = 0;
    virtual void on_resize(Extent) = 0;
    virtual std::string_view type_name() const noexcept = 0;
};
```

The application supplies the command buffer and render view. A renderer may
hold references to a device, pipelines, and scene data, but it must not create
an implicit frame loop or surface.

## Shared renderer data

Define stable data contracts for:

- camera matrices and position;
- object transforms;
- material parameters;
- directional, point, and spot lights;
- shadow metadata;
- frame index and time;
- viewport and output target.

Use `ParameterBlock`, uniform buffers, storage buffers, and argument buffers
according to update frequency. Avoid copying all state into a single large
buffer if Metal argument tables or smaller dynamic slices are more suitable.

## Forward renderer

### Scope

- Opaque and transparent draw lists.
- Depth prepass or depth-tested forward pass.
- Directional shadow pass.
- Material binding.
- Instanced batches.
- Lines, points, billboards, and overlays.
- Optional mesh-shader path.

### Submission policy

1. Gather visible drawables from the scene.
2. Sort or batch by pipeline/material/mesh according to the chosen strategy.
3. Prepare dynamic frame and instance data.
4. Encode shadow and scene passes.
5. Encode overlay work with explicit load/store actions.

Metal-specific decisions:

- use argument buffers for large material/texture sets;
- use shared dynamic data when cheap and private resources when appropriate;
- use mesh shaders for meshlet paths rather than converting them to indexed
  draws at the renderer boundary;
- use indirect commands when GPU culling is enabled.

## Forward+ renderer

### Scope

- Cluster or tile light assignment.
- Compute preparation pass.
- Per-cluster light index/count buffers.
- Opaque and transparent consumption.
- Configurable maximum lights per cluster.
- Diagnostics for overflow.

### Pass flow

```text
update camera/lights
    → compute cluster bounds
    → compute light assignment
    → render opaque
    → render transparent
    → overlays
```

The compute pass should be a normal `ComputeEncoder` pass. Resource
dependencies and synchronization must be explicit; do not assume Vulkan-style
barriers are required where Metal's encoder ordering and hazard tracking
already provide the needed visibility.

## GPU-driven rendering

Add an optional path that:

- performs visibility/culling on the GPU;
- writes instance or indirect-command data;
- uses argument buffers for shared resource tables;
- uses an ICB or supported indirect draw path;
- reports fallback to CPU batching when the capability is unavailable.

Keep GPU-driven state separate from the simple CPU submission path so small
applications do not pay its setup cost.

## Mesh-shader renderer

Add a renderer path for:

- meshlet buffers;
- object-stage culling;
- mesh payload metadata;
- LOD and visibility selection;
- mesh-threadgroup dispatch.

The renderer should choose this path only when its pipeline and device
capabilities satisfy the scene's requirements. A scene may contain both
mesh-shader and indexed representations.

## Resize and target ownership

Renderers may own size-dependent offscreen targets, but:

- the surface owns its drawable;
- the application or scheduler owns frame acquisition;
- the renderer receives resize notifications;
- target recreation does not invalidate resources still referenced by an
  in-flight command buffer;
- memoryless targets are used only for transient passes.

## Performance and diagnostics

Expose optional statistics:

- submitted draw/dispatch count;
- visible and culled objects;
- pipeline/material switches;
- cluster overflow;
- mesh fallback selection;
- ICB/argument-buffer use;
- pass and GPU timing labels.

These statistics should be collected without requiring debug-only behavior in
the command path.

## Implementation steps

1. Define `Renderer`, `RenderView`, and shared frame-data types.
2. Implement a minimal indexed Forward renderer.
3. Add material/pipeline and dynamic-buffer synchronization.
4. Add shadows, transparent batches, lines, points, and overlays.
5. Implement Forward+ light clustering through compute.
6. Add argument-buffer and mesh-shader paths.
7. Add GPU culling and indirect/ICB submission.
8. Add resize and in-flight target lifetime tests.
9. Add renderer examples and performance counters.

## Acceptance criteria

- A renderer records into an application-provided `CommandBuffer`.
- No renderer requires a global context or owns a window.
- Forward rendering supports opaque, transparent, depth, shadow, and overlay
  paths.
- Forward+ produces and consumes clustered-light data through Metal compute.
- Mesh and GPU-driven paths use native features when supported and report
  fallbacks otherwise.
- Resize and in-flight command-buffer lifetimes are safe.

## Implementation in this slice

Implemented as a Swift renderer layer above the existing Metal wrappers:

- `Renderer` with explicit Forward and Forward+ modes; it receives a
  caller-owned `Device`, `CommandBuffer`, and `RenderPassDescriptor` and does
  not create a window, surface, or command queue;
- `RenderView`, `RendererStatistics`, and `ForwardPlusConfiguration` value
  contracts;
- `RenderBatch` for explicit vertex/index data, pipeline selection,
  transparency, labels, and optional mesh/indirect submission metadata;
- indexed and non-indexed draw encoding through the existing render encoder;
- capability-aware mesh and indirect paths with explicit fallback pipelines;
  unsupported paths fail rather than silently changing semantics;
- resize generation tracking and Forward+ cluster-count planning without
  taking ownership of size-dependent surface targets;
- renderer lifecycle, batch registration, statistics, and API-shape tests.

The C++ facade is generated from the Swift module and is organized under
`include/mt/renderer.hpp`. The renderer is intentionally a small submission
layer; scene, material, light, meshlet, and built-in shader ownership remain
with Plan 08.

## Deferred follow-up

- GPU light-cluster preparation and consumption through built-in compute
  shaders; Plan 08 supplies the light data and shader/layout contracts. The
  renderer implementation belongs to
  [Plan 15 — Renderer completion](15-renderer-completion.md).
- Shadow, depth-prepass, transparent sorting, lines, points, billboards, and
  overlay pass scheduling belong to Plan 15.
- Material/argument-buffer binding tables and pipeline caches belong to Plans
  13, 15, and 16.
- Full GPU culling/LOD generation and meshlet upload management belong to
  Plans 15 and 16.
- Persistent renderer statistics and GPU counter integration beyond the
  command-buffer timing exposed by Plan 06 belong to Plan 15.

Build, C++ ABI, shader compilation, and runtime verification are intentionally
pending on a Metal-capable macOS machine; renderer evidence and examples are
tracked in
[Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).

