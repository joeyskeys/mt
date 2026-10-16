# Plan 00 — Module architecture and execution model

**Status:** proposed — Swift-first implementation selected
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Role:** shared constraints for all implementation modules

## Goal

Turn the high-level wrapper design into independently implementable modules
without losing Metal's native programming model.

The module architecture must allow another C++ project to use the low-level
library directly, while leaving renderer, viewport, and window conveniences
optional.

## Native object model

The core abstraction graph is:

```text
mt::Device
  ├── mt::CommandQueue
  │     └── mt::CommandBuffer
  │           ├── mt::RenderEncoder
  │           ├── mt::ComputeEncoder
  │           └── mt::BlitEncoder
  ├── mt::Buffer / mt::Texture / mt::Heap
  └── mt::RenderPipeline / mt::ComputePipeline / ...
```

The graph maps directly to:

```text
MTLDevice
  ├── MTLCommandQueue
  │     └── MTLCommandBuffer
  │           ├── MTLRenderCommandEncoder
  │           ├── MTLComputeCommandEncoder
  │           └── MTLBlitCommandEncoder
  └── MTLResource / MTLRenderPipelineState / ...
```

`Surface`, `Drawable`, and `Frame` are presentation-side objects. They do not
replace `Device`, `CommandQueue`, or `CommandBuffer`.

The implementation language for the core is Swift. C++ consumers use the
generated Swift C++ interoperability header and link the Swift library/runtime.
The generated header is a build artifact and must not be hand-edited or
checked into source control.

## Core versus optional modules

### Required core

- Swift package/build target and generated C++ ABI boundary.
- Device selection and capability discovery.
- Command queues, command buffers, and encoder lifetimes.
- Offscreen rendering.
- Buffer, texture, sampler, pipeline, and synchronization resources.
- MSL/metallib loading and pipeline creation through Swift Metal APIs.

### Native extension layer

- Mesh/object shaders.
- Argument buffers.
- Indirect command buffers.
- Tile shaders and tile-local storage.
- Memoryless attachments.
- SIMD-group and Apple GPU optimizations.
- Ray tracing and intersection functions.
- GPU counters and capture labels.

These are optional at runtime, but their APIs are part of the design.

### Higher-level modules

- Forward and Forward+ rendering.
- Scene, assets, materials, lights, and built-in shaders.
- Viewport features and picking.

### Optional host modules

- AppKit and `CAMetalLayer`.
- `MTKView`.
- GLFW and Qt.
- ImGui, fonts, Python, and external-resource interop.

## Cross-module conventions

### Ownership

- Wrapper objects own or retain their native Metal object according to one
  documented policy.
- A `Device` must outlive resources created from it.
- A `CommandQueue` must outlive command buffers created from it.
- A command buffer must remain alive until Metal has finished executing it.
- Encoders are scoped to their command buffer and must be ended before the
  command buffer is committed.
- Surface drawables are transient and must not be cached across frames.

### Threading

- Device and resource creation should be safe either from one documented
  thread or under documented synchronization.
- Independent command buffers may be encoded concurrently when Metal permits
  it.
- A single encoder must not be mutated concurrently.
- Higher-level registries must state whether reads and writes are thread-safe.

### Errors

Use structured C++ errors or a `Result<T, Error>`-style API for:

- no compatible Metal device;
- unsupported requested feature;
- invalid resource or pipeline descriptors;
- unavailable drawable;
- command-buffer execution failure;
- shader compilation or metallib loading failure.

Errors should include the operation, the relevant capability or descriptor,
and the native Metal message when available.

### Capability gating

Every native feature has:

1. a capability query;
2. a creation-time validation path;
3. a clear unsupported error;
4. a fallback only if the fallback preserves useful semantics.

No module may silently convert a requested mesh, tile, argument-buffer, or ray
tracing path into an unrelated baseline path.

## Vertical milestones

### Milestone A — external C++ triangle

- CMake package and public headers.
- `Device`, `CommandQueue`, `CommandBuffer`.
- Offscreen surface.
- MSL/metallib render pipeline.
- Readback test.

### Milestone B — windowed native Metal consumer example

- AppKit/`CAMetalLayer` adapter.
- Drawable acquisition and presentation.
- A planned object/mesh/fragment example rendered through C++.

### Milestone C — reusable rendering core

- Textured indexed and instanced geometry.
- Compute and blit encoders.
- Resource synchronization and readback.
- Pipeline cache and explicit binding layouts.

### Milestone D — Metal-native rendering

- Mesh-shader path.
- Argument-buffer material tables.
- GPU culling and indirect commands.
- Tile/memoryless example where supported.

### Milestone E — vkkk-level toolkit

- Forward/Forward+ renderer.
- Scene and asset managers.
- Viewport and picking.
- Optional integrations.

## Out of scope for the first vertical slice

- A Vulkan compatibility layer.
- GLSL/SPIR-V as the required shader input.
- A global resource-name registry.
- A mandatory window or event loop.
- CUDA parity on macOS.
- A full scene/renderer/viewport implementation before the low-level API is
  validated by an external C++ consumer.

## Acceptance criteria

This overview is satisfied when:

- every module has one primary ownership boundary;
- no plan requires a synthetic global `Context`;
- the core can be consumed from C++ without importing Swift source or AppKit;
- Metal-native capabilities are represented as deliberate APIs;
- the module dependency order in `README.md` remains acyclic;
- the first vertical slice can be implemented without designing the entire
  renderer in advance.

