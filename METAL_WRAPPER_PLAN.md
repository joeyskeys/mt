# `mt` Metal C++ Wrapper — Feature and Implementation Plan

This document translates the architecture described by
[`vkkk/PROJECT_STRUCTURE.md`](../vkkk/PROJECT_STRUCTURE.md) into a macOS Metal
library plan for `mt`.

The implementation-oriented module plans are indexed in
[`docs/plans/README.md`](docs/plans/README.md).

The goal is not to reproduce Vulkan terminology or to force Metal into a
lowest-common-denominator API. The goal is to provide the same useful
application-level capabilities as vkkk while making Metal-specific GPU
features available through the normal API when the device supports them.

## 1. Target

`mt` should become a C++20 library that other projects can link against on
macOS. It should provide:

- A Swift Metal core exposed to C++ through Swift's generated C++ interop
  header.
- C++-usable device, command-queue, command-buffer, frame, and presentation
  types that follow Metal's native ownership model.
- Named buffers, textures, samplers, render targets, depth resources, meshes,
  pipelines, and compute resources.
- Graphics, compute, mesh/object-shader, indirect, and GPU-driven rendering.
- Renderer, scene/asset, and composable viewport layers corresponding to the
  useful parts of vkkk.
- Optional window, GUI, font, Python, and host-application integrations.
- Explicit Metal capability discovery and access to Metal-native extensions.

The public C++ API is generated from a constrained public Swift API. C++
consumers link the Swift library/runtime; they do not import Swift source.
AppKit, `MTKView`, and `CAMetalLayer` integrations should remain optional host
adapters rather than requirements of the core renderer.

## 2. Current `mt` baseline

The repository currently contains:

- A Swift `MTCore` library target with device, queue, command-buffer, encoder,
  surface, drawable, frame, resource, and capability wrappers.
- Swift/C++ interoperability enabled through CMake and SwiftPM.
- A generated `MTCore-Swift.h` integration path with C++ umbrella aliases.
- C++ public-header, command/surface/resource API, consumer, and package-shape
  tests.
- Swift-side capability, command, surface, and resource runtime tests.

The renderer, shader, scene, viewport, and host-integration modules remain
planned work. Higher-level resource registries are also deferred. Mesh-shader
examples will be added under the module plan that owns their pipeline rather
than kept as a separate application demo.

## Design correction: Metal does not require a global `Context`

Metal is not organized around a Vulkan-style context object. Its native
command and ownership model is:

```text
MTLDevice
  ├── MTLCommandQueue
  │     └── MTLCommandBuffer
  │           ├── MTLRenderCommandEncoder
  │           ├── MTLComputeCommandEncoder
  │           └── MTLBlitCommandEncoder
  ├── MTLBuffer / MTLTexture / MTLHeap
  └── MTLRenderPipelineState / MTLComputePipelineState / ...
```

`MTLDevice` represents a GPU and creates device-owned objects. A long-lived
`MTLCommandQueue` creates command buffers. A command buffer contains render,
compute, or blit encoders and is committed for execution. A window surface
such as `CAMetalLayer` supplies drawables; it is not a Vulkan swapchain.

The `mt` core must preserve this model:

- `mt::Device` wraps the Metal device and exposes capabilities and factories.
- `mt::CommandQueue` wraps a command queue.
- `mt::CommandBuffer` wraps one unit of submitted work.
- `mt::RenderEncoder`, `mt::ComputeEncoder`, and `mt::BlitEncoder` wrap the
  corresponding Metal encoders.
- `mt::Surface` supplies a drawable or an offscreen render target.
- `mt::Frame` may coordinate a temporary window frame, but must not own the
  device or replace command-buffer ownership.
- A higher-level `mt::FrameScheduler` or renderer facade may combine these
  objects for convenience, but it is not a required Metal concept.

Therefore, this document uses the word *context* only for an optional
application-level coordinator. The foundational API should not require
`mt::Context`. The vkkk `Context` is a useful collection of responsibilities,
not a type that should be translated one-for-one into Metal.

The selected implementation boundary is Swift-first. The core uses Swift's
Metal framework APIs and enables Swift/C++ interoperability. Swift generates a
Clang-compatible C++ header for supported public types and functions. The
wrapper should avoid a handwritten Objective-C++ implementation layer.

C++ consumers must include the generated header and link the Swift library.
The public Swift surface therefore needs to stay within the supported
Swift/C++ interop subset: value types, classes, enums, strings, arrays,
optionals, and opaque pointers where appropriate. Unsupported Swift features
such as arbitrary async/generic APIs must not leak into the generated C++
surface.

Reference material for this model:

- [Metal command organization and execution
  model](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Cmd-Submiss/Cmd-Submiss.html)
- [Mixing Swift and C++](https://swift.org/documentation/cxx-interop/)
- [Calling Swift from C++](https://github.com/apple/swift/blob/main/docs/CppInteroperability/UserGuide-CallingSwiftFromC%2B%2B.md)

## 3. vkkk capability baseline and Metal mapping

| vkkk capability | `mt` equivalent | Metal-specific design |
| --- | --- | --- |
| `vkkk::Context` responsibilities | `mt::Device`, `mt::CommandQueue`, `mt::Surface`, and optional `mt::FrameScheduler` | Split across Metal's native object graph; there is no required global `mt::Context`. |
| Vulkan device and queue | `mt::Device` / `mt::CommandQueue` | `mt::Device` creates resources, pipeline states, and queues; a queue creates command buffers. |
| Vulkan swapchain and surface | `mt::Surface` / drawable provider | Wraps `CAMetalLayer`, `MTKView`, or an offscreen target. Metal has drawables rather than a Vulkan swapchain. |
| `Context::begin_frame` / `end_frame` | `mt::Surface` + `mt::Frame` or optional scheduler | Acquires a drawable, creates a command buffer, presents, and commits without pretending Metal has Vulkan acquire semantics. |
| Vulkan command buffer | `mt::CommandBuffer` | Creates Metal render, compute, and blit encoders and commits through its queue. |
| Vulkan render passes | `mt::RenderPassDesc` | Maps load/store actions, clear values, resolve targets, depth/stencil, and tile data to `MTLRenderPassDescriptor`. |
| `Pipeline` | `mt::RenderPipeline` | Supports vertex/fragment and object/mesh/fragment pipelines. |
| `ComputePipeline` | `mt::ComputePipeline` | Supports threadgroup memory, SIMD-group features, indirect dispatch, and function specialization. |
| Descriptor sets and reflected bindings | `mt::BindingLayout` / argument tables | Uses explicit Metal slots and argument buffers instead of emulating Vulkan descriptor sets. |
| UBO / SSBO | `mt::UniformBuffer` / `mt::StorageBuffer` | Uses shared, managed, or private storage according to update frequency and device capabilities. |
| Push constants | `mt::ParameterBlock` | Uses `set*Bytes`, ring-buffer allocations, or argument-buffer data; the API should not assume a Vulkan push-constant limit. |
| `MeshGPU`, `LinesGPU`, `PointsGPU` | Corresponding named Metal resources | Supports ordinary indexed draws and mesh/object-shader paths. |
| Indirect buffer | `mt::IndirectBuffer` / `mt::IndirectCommandBuffer` | Exposes GPU-generated commands and Metal ICBs where supported. |
| Texture, cubemap, render target | `mt::Texture`, `mt::Sampler`, `mt::RenderTarget` | Covers 1D/2D/3D, arrays, cubemaps, MSAA, resolve, usage flags, and readback. |
| Depth attachment | `mt::DepthAttachment` | Uses Metal depth/stencil textures and depth/stencil state. |
| Shader module and reflection | `mt::ShaderLibrary` / pipeline reflection | Uses MSL source or precompiled metallib, function constants, explicit binding metadata, and Metal reflection. |
| Forward / Forward+ renderer | `ForwardRenderer` / `ForwardPlusRenderer` | Uses compute clustering, argument buffers, instancing, and GPU-driven submission where useful. |
| `Scene`, `DrawableMgr`, `LightMgr` | `mt::Scene`, `mt::DrawableManager`, `mt::LightManager` | Keeps CPU scene data separate from GPU resource ownership. |
| `vp::Viewport<...>` | `mt::vp::Viewport<...>` | Keeps compile-time feature composition and picking/scene/overlay phases. |
| `WindowBackend` | `mt::SurfaceBackend` plus host adapters | Core only needs drawable acquisition and size/resize state; AppKit, GLFW, and Qt adapters can be separate. |
| ImGui and font helpers | Optional Metal integrations | Must not be required by the core library. |
| CUDA/Vulkan external memory | Metal external-resource integration | Do not promise CUDA parity on macOS; investigate IOSurface, shared events, and other Metal-supported interop instead. |

## 4. Features to implement

### 4.1 Library, build, and ABI

- Add an installable Swift library target with generated C++ interop header.
- Keep CMake and Xcode/SwiftPM consumption paths aligned.
- Link the Swift target to Metal and Foundation; keep UI frameworks optional.
- Install the generated `MTCore-Swift.h` beside the C++ umbrella headers.
- Keep handwritten public C++ aliases/adapters small and free of Objective-C
  protocol types.
- Use Swift reference/value semantics for core ownership and expose only the
  C++-interop-supported representation.
- Provide opaque native-handle access from Swift only for advanced applications
  and document that the pointer is borrowed.
- Define threading rules: resource creation and registry mutation should have
  a clear owner; command recording should allow independent encoders or
  explicitly document serialization requirements.
- Make external C++ consumption a first-class build path. A consumer should
  include the generated C++ header through `mt/mt.hpp`, link the Swift library,
  and receive the required Swift runtime/framework linkage from the package.
- Keep the generated header out of source control; it is a build/install
  artifact tied to the Swift compiler and module version.

### 4.2 Device, queue, and capability discovery

Implement the public Swift `Device` class as the root wrapper around
`MTLDevice`; expose it to C++ through the generated header:

- Device selection and native-device lifetime.
- Creation of command queues, buffers, textures, heaps, samplers, and pipeline
  states.
- Debug labels, validation, GPU capture markers, and device error reporting.
- Device limits and feature capabilities.

Implement the public Swift `CommandQueue` class as a separately owned
long-lived object:

- Create command buffers.
- Optionally expose queue priority and scheduling configuration supported by
  the target Metal SDK.
- Keep queue ownership independent from surfaces and renderers.

Resource registries, pipeline caches, and frame scheduling may be separate
objects. They should not be hidden mandatory state inside `mt::Device` or a
global context facade.

Expose a capability object similar to:

```cpp
struct DeviceCapabilities {
    uint32_t family_major;
    uint32_t family_minor;
    bool supports_mesh_shaders;
    bool supports_argument_buffers;
    bool supports_indirect_command_buffers;
    bool supports_tile_shaders;
    bool supports_memoryless_attachments;
    bool supports_ray_tracing;
    bool supports_dynamic_libraries;
    bool supports_counter_sampling;
    // Alignment, threadgroup, texture, sample-count, and buffer limits.
};
```

The exact fields should be derived from runtime Metal queries rather than
assumed from the machine model. Unsupported features must produce a useful
capability result or a clear error, not a silent fallback with different
rendering semantics.

The intended low-level creation flow is close to Metal itself:

```cpp
mt::Device device = mt::Device::system_default();
mt::CommandQueue queue = device.create_command_queue();
mt::CommandBuffer command_buffer = queue.make_command_buffer();
```

The wrapper may provide factories and convenience constructors, but it should
not make applications construct a synthetic context before they can use a
device or command queue.

### 4.3 Surface, command buffer, and frame lifecycle

The core API should expose direct Metal-style submission:

```cpp
auto drawable = surface.next_drawable();
auto command_buffer = queue.make_command_buffer();
auto render_pass = surface.make_render_pass(drawable);
auto encoder = command_buffer.make_render_encoder(render_pass);
// Bind state and encode draw calls.
encoder.end_encoding();
command_buffer.present(drawable);
command_buffer.commit();
```

An optional scheduler can provide a convenient application frame boundary:

```cpp
mt::Frame frame = scheduler.begin_frame(surface, queue);
if (frame) {
    update_application_state(frame);
    auto encoder = frame.command_buffer().make_render_encoder(
        frame.render_pass());
    // Bind state and encode draw calls.
    encoder.end_encoding();
    scheduler.end_frame(frame);
}
```

`mt::Frame` is a short-lived coordination value. It should reference a
drawable and command buffer; it should not become a global owner of all
resources or a replacement for `MTLCommandQueue` and `MTLCommandBuffer`.

Required behavior:

- Drawable acquisition from `CAMetalLayer` and an offscreen mode for tests.
- Resize and drawable-size handling, including scale-factor changes.
- Explicit render-pass load/store/resolve behavior.
- Command-buffer completion/error reporting.
- Present scheduling and frame pacing.
- Support for more than one command buffer when a workload benefits from
  separate graphics, compute, or blit work.
- A no-window path for asset processing, compute jobs, and deterministic
  render-to-texture tests.

Unlike Vulkan, Metal does not expose a user-managed swapchain acquisition
protocol. The abstraction should preserve the application-level frame contract
without pretending that the underlying synchronization is identical.

Command buffers should own the ordering of their encoders. The wrapper should
allow multiple command buffers and queues where the workload needs them, while
leaving scheduling decisions visible instead of hiding all work behind one
global context.

### 4.4 Resource management and synchronization

Implement resources created by `mt::Device`, corresponding to vkkk's UBO, SSBO,
texture, target, depth, mesh, lines, points, and indirect resources:

- `Buffer`, `UniformBuffer`, `StorageBuffer`, and dynamic/ring buffers.
- `Texture`, `TextureView`, `Sampler`, and texture arrays/cubemaps.
- `RenderTarget`, `DepthAttachment`, MSAA targets, and resolve targets.
- `Heap` and resource aliasing support where it improves memory use.
- Readback buffers and pixel/texture readback helpers.
- Optional argument-buffer-backed resource tables.
- Resource usage declarations and hazard tracking.
- Optional named resource registries with a documented ownership policy.

Typed resource objects and explicit references are the default. String-keyed
global maps are a convenience module for vkkk-style applications, not a
requirement of the Metal wrapper.

Storage and upload policy must be Metal-aware:

- Use shared storage for frequently CPU-updated small data when appropriate.
- Use private storage plus blit/upload staging for large GPU-only resources.
- Handle managed storage and explicit synchronization on macOS devices that
  require it.
- Use memoryless attachments when the device exposes them and a render target
  never needs to be stored outside the tile pass.
- Do not impose a Vulkan-style staging copy on unified-memory devices when a
  direct shared update is the better path.

Synchronization primitives should cover Metal fences/events, command-buffer
completion, and resource visibility. The API should offer the semantics needed
by an application without requiring applications to manipulate raw Metal
hazard APIs for ordinary work.

### 4.5 Shader and pipeline system

Implement a Metal-native shader path rather than requiring GLSL/SPIR-V:

- Load precompiled metallib files.
- Optionally compile MSL source during development.
- Build and cache render, mesh, compute, and tile-related pipeline states.
- Support vertex/fragment pipelines and object/mesh/fragment pipelines.
- Support `MTLVertexDescriptor`, blending, depth/stencil state, raster state,
  sample count, and attachment formats.
- Support function constants and specialized pipeline variants.
- Support binary archives and dynamic libraries where the deployment target
  and device allow them.
- Provide pipeline reflection for resource usage and threadgroup limits.
- Keep explicit CPU/MSL layout metadata beside built-in shader definitions.
- Provide actionable diagnostics for missing functions, incompatible formats,
  unsupported shader stages, and limit violations.

Metal has no direct equivalent of Vulkan descriptor-set layout reflection.
Resource indices and argument-buffer layouts should therefore be explicit and
stable, with reflection used for validation and tooling rather than as the
only source of binding truth.

The build must include a reproducible MSL-to-metallib step for library users
and examples. A future built-in mesh-shader sample should be the first shader
converted into this pipeline.

### 4.6 Command buffers, encoders, and drawing

`mt::CommandBuffer` should create focused encoder types rather than pretending
there is one universal Metal command context:

- `mt::RenderEncoder` for one render pass.
- `mt::ComputeEncoder` for one compute pass.
- `mt::BlitEncoder` for copies, clears, resolves, and mipmap generation.
- An optional parallel-render wrapper when multi-threaded encoding is useful.

The encoders should expose the operations needed by vkkk:

- Named pipeline binding and resource binding.
- Vertex, index, instance, primitive, and indexed drawing.
- Indirect draw and indirect dispatch.
- Object/mesh shader dispatch using `drawMeshThreadgroups`.
- Push-parameter equivalent updates through parameter blocks or dynamic
  buffers.
- Viewport, scissor, stencil, blend, and depth state.
- Debug groups, labels, timestamps, and counter samples.
- Resource copies, clears, resolves, and readbacks.

The common API should not hide the distinction between render, compute, and
blit encoders. It should make pass transitions explicit so Metal's load/store,
hazard, and tile-memory behavior remains controllable.

### 4.7 Metal-native GPU features

These are first-class targets, not features to discard for portability:

#### Mesh and object shaders

- Keep object and mesh stages in the core graphics pipeline model.
- Expose payload size, threadgroup sizes, mesh output limits, and dispatch
  dimensions in pipeline descriptions.
- Support meshlet data, GPU culling, LOD selection, and payload-driven
  visibility.
- Provide an indexed/vertex fallback for devices without mesh shaders, but
  report which path was selected and do not make the fallback the only API.

#### Argument buffers

- Add typed argument-buffer layouts for material, scene, texture, and instance
  data.
- Support arrays of textures, samplers, and buffers for bindless-like access.
- Allow applications to choose direct slots for simple paths and argument
  buffers for large or frequently changing resource sets.

#### Indirect command buffers and GPU-driven rendering

- Wrap `MTLIndirectCommandBuffer` and GPU-generated draw/dispatch data where
  supported.
- Make culling, batching, and command generation usable by Forward+ and
  viewport features.
- Keep the API capability-gated because command types and mesh support vary by
  OS/device generation.

#### Tile-based rendering

- Represent tile shaders, tile threadgroup memory, image blocks, and
  raster-order synchronization as explicit optional pass capabilities.
- Use memoryless color/depth attachments and tile-local work to reduce
  bandwidth when the device supports them.
- Do not force tile-only algorithms into the ordinary fragment/compute API;
  expose a clear tile-pass extension that can coexist with regular passes.

#### SIMD-group and Apple GPU execution features

- Expose subgroup/SIMD-group operations through shader support and capability
  checks.
- Make threadgroup memory, occupancy limits, and SIMD width available to
  pipeline planning.
- Add specialized matrix or acceleration paths only when the runtime device
  reports support.

#### Ray tracing and intersection functions

- Add an optional acceleration-structure and ray-tracing module.
- Keep it separate from the baseline Forward/Forward+ path so devices without
  Metal ray tracing remain usable.
- Expose intersection functions, acceleration-structure build/update, shader
  tables, and ray dispatch where supported.

#### Profiling and debugging

- Integrate GPU counter sampling, signposts/labels, command-buffer timings,
  and Metal capture markers.
- Make debug validation and capture support available without changing the
  application render code.

### 4.8 Renderer layer

Mirror the active vkkk renderer contract:

```cpp
class Renderer {
public:
    virtual ~Renderer() = default;
    virtual bool initialize(Device&) = 0;
    virtual void shutdown() = 0;
    virtual void update() {}
    virtual void record_commands(CommandBuffer&, uint32_t drawable_index) = 0;
    virtual void on_resize(uint32_t width, uint32_t height) = 0;
    virtual std::string_view type_name() const = 0;
};
```

Implement in stages:

- `ForwardRenderer`: opaque/transparent batches, depth, shadows, overlays.
- `ForwardPlusRenderer`: clustered light preparation using compute, storage
  buffers, argument buffers, and instanced submission.
- Deferred rendering only after render-target and material infrastructure is
  stable.
- Mesh-shader renderer paths for meshlet-driven scenes.
- Optional GPU-driven batching using indirect command buffers.

Renderer code should consume `Device`, resource objects, command buffers, and
scene data without owning the host window or application lifecycle. A renderer
may receive a `CommandQueue` or scheduler from its application, but should not
hide queue and frame ownership inside a mandatory context object.

### 4.9 Scene, assets, and built-in shaders

Provide the vkkk-level domain modules after the low-level API is usable:

- `Scene` and `SceneObject` with named objects and transforms.
- CPU-side `Mesh`, `MeshView`, `Lines`, `Points`, and curve types.
- `DrawableManager` for imported/procedural meshes and GPU synchronization.
- `LightManager` with directional, point, spot, and clustered-light storage.
- Material and texture resource descriptions.
- Assimp/importer integration as an optional module.
- Built-in MSL plus matching C++ layout types for:
  - fixed-color geometry;
  - Phong and clustered Phong;
  - PBR;
  - directional shadows;
  - mesh-shader line/normal visualization;
  - billboards and text;
  - light clustering.

Shader buffer structs must be kept adjacent to their MSL definitions and
validated for size/alignment. Metal's packing rules must be treated as a
separate ABI contract rather than assumed to match Vulkan/GLSL layouts.

### 4.10 Viewport and picking

Port the composable viewport model:

- Compile-time or type-erased feature composition.
- Feature hooks for attach, resize, update, and command recording.
- Picking, scene, and screen-overlay phases.
- Frame axes, grid, object picking, and vertex picking.
- Offscreen ID/depth targets and readback for picking.
- Overlay passes that preserve the scene color/depth according to explicit
  load/store actions.

Picking should use Metal render targets, atomics, or compute reduction where
appropriate, rather than assuming Vulkan image/barrier behavior.

### 4.11 Window, UI, font, and optional integrations

Implement host integrations separately from the core:

- AppKit + `CAMetalLayer` adapter.
- Optional `MTKView` adapter for simple applications.
- Optional GLFW and Qt surface adapters if demand justifies them.
- Toolkit-neutral resize, close, input, and drawable-size contracts.
- ImGui Metal backend integration.
- Font-to-texture or glyph-atlas rendering.
- Optional Python bindings after the C++ API has stabilized.
- IOSurface/shared-event or other Metal-supported interop where a real use
  case exists.

CUDA/Vulkan external-memory behavior from vkkk should not be copied as a
promise on macOS. It should be replaced by a separately designed Metal
interop module with documented platform and device limitations.

## 5. Metal feature policy

The wrapper should use a two-level API:

1. **Core semantic API** — stable concepts needed by normal rendering:
   devices, queues, command buffers/encoders, resources, passes, pipelines,
   draws, dispatch, scenes, and viewports.
2. **Metal capability API** — explicit extensions for mesh shaders, argument
   buffers, ICBs, tile passes, memoryless attachments, ray tracing, counters,
   and other device-specific facilities.

This avoids two failure modes:

- reducing Metal to an indexed-draw abstraction because another backend lacks a
  feature;
- making every application depend on one GPU family and failing at runtime on
  older or Intel Macs.

Recommended rules:

- Query capabilities at runtime and expose them to applications.
- Make a supported Metal feature available through the normal C++ wrapper.
- Add fallbacks only when they preserve useful semantics.
- Let applications request a required feature and fail early with a useful
  diagnostic when it is unavailable.
- Preserve access to native Metal handles for advanced integrations.
- Keep feature-specific types in namespaces such as `mt::metal` when they
  cannot be represented meaningfully in the core API.
- Keep a convenience `FrameScheduler` or renderer facade optional. Do not
  require a synthetic `Context` just to use a Metal device or command queue.
- Test both the native path and the fallback path when a fallback exists.

## 6. Proposed repository structure

```text
include/mt/
  mt.hpp                    # Includes the generated Swift C++ header
  swift_api.hpp             # C++ namespace aliases/adapters
  native_handle.hpp
  renderer/
  scene/
  vp/
  metal/                    # Metal-native extension types
Sources/MTCore/
  MTCore.swift              # Swift Metal implementation
tests/MTCoreTests/
  MTCoreTests.swift         # Swift-side unit/runtime tests
src/                      # Optional C++ consumer helpers only
  renderer/
  scene/
  vp/
  metal/
shaders/
  built_in/
examples/
tests/
cmake/
```

The exact split can change, but the public/private boundary should remain
clear: applications include `include/mt` and the generated C++ header, while
Metal object ownership stays inside the Swift module.

## 7. Staged implementation order

### Phase 0 — API and build foundation

- Enable Swift/C++ interoperability in the Swift target.
- Add CMake/SwiftPM targets and install/export rules.
- Generate and install the Swift C++ compatibility header.
- Add public header compilation tests.
- Add Swift-side device/command-queue smoke tests.
- Define error, ownership, threading, and capability conventions.

**Done when:** a separate C++20 program can link `mt`, create a device, and
report capabilities through the generated header while linking the Swift
library, without importing Swift source or `MTKView`.

### Phase 1 — Device, surface, and command lifecycle

- Implement Swift `Device`, `CommandQueue`, and `CommandBuffer` ownership.
- Implement `Surface` for `CAMetalLayer` and an offscreen target.
- Implement direct drawable/command-buffer submission, plus an optional
  `FrameScheduler` for begin/end convenience, resize, present, and completion
  errors.
- Add a small C++ consumer example that uses the library.

**Done when:** the sample renders through the C++ API on a window and in an
offscreen test.

### Phase 2 — Resources and render/compute passes

- Implement buffers, textures, samplers, depth, render targets, uploads, and
  readbacks.
- Implement render, compute, and blit command encoders.
- Implement load/store/resolve, synchronization, labels, and debug groups.

**Done when:** a C++ application can render a textured indexed mesh, run a
compute pass, and read back an offscreen result.

### Phase 3 — Shaders and pipelines

- Add MSL/metallib packaging and loading.
- Add pipeline creation, explicit binding layouts, function constants, and
  reflection validation.
- Convert the existing mesh shader into a reusable pipeline description.

**Done when:** vertex/fragment, compute, and object/mesh/fragment pipelines can
  be created by name and validated against their resource layouts.

### Phase 4 — Geometry and GPU-driven commands

- Add mesh, line, point, indexed, instanced, indirect, and mesh-shader draws.
- Add argument buffers and resource tables.
- Add ICB support where available.
- Add capability-aware mesh-shader fallback.

**Done when:** the wrapper supports the main vkkk drawing operations through
typed command buffers and encoders without requiring raw Metal calls.

### Phase 5 — Renderer, scene, and built-in features

- Add scene/object/mesh/light managers.
- Port Forward and Forward+.
- Add built-in materials, shadows, clustering, billboards, and text.
- Add GPU-driven and meshlet examples.

**Done when:** a small scene can follow the vkkk-style application flow using
only the C++ wrapper and renderer modules.

### Phase 6 — Viewport, picking, and integrations

- Add the feature-composed viewport.
- Add axes, grid, object picking, and vertex picking.
- Add AppKit/GLFW/Qt, ImGui, font, and optional Python modules as separate
  targets.
- Add Metal-native tile, memoryless, ray-tracing, and profiling examples.

**Done when:** the library has a usable editor-style viewport and each
  optional integration can be enabled without expanding the core dependency
  set.

## 8. Verification requirements

- Compile the generated public C++ header and Swift module in Debug/Release.
- Build Debug and Release libraries and an external consumer example.
- Run offscreen render/readback tests for clear, depth, texture, blending,
  compute, and picking paths.
- Test resize, drawable loss, command-buffer errors, and device capability
  failures.
- Test on Apple Silicon with mesh shaders and on any available non-mesh
  Metal device using the documented fallback.
- Capture representative frames in Xcode GPU tools.
- Check C++/MSL buffer sizes, alignment, texture formats, and threadgroup
  limits at pipeline creation.
- Keep examples as separate consumers of the installed library; do not make
  an application target part of the core package.

## 9. Immediate next step

The first implementation slice should be a Swift library skeleton containing:

1. Swift `DeviceCapabilities`.
2. Swift `Device` and `CommandQueue`.
3. `mt::Surface` for an offscreen target and one AppKit/`CAMetalLayer`
   adapter.
4. Swift `CommandBuffer`, focused encoders, and optional `Frame` exposed
   through generated C++ bindings.
5. A small C++ consumer example exercising the first render path.

That slice will settle the most important early choices—native binding
strategy, public handle ownership, Metal shader packaging, and frame
semantics—before scene, renderer, and viewport APIs are added. It will also
prove that an external C++ project can use the Swift-backed `mt` module
without adopting a synthetic Vulkan-style context.
