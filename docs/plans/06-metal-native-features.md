# Plan 06 — Metal-native GPU features

**Status:** proposed
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** [Plan 02](02-device-and-capabilities.md), [Plan 03](03-commands-surfaces-and-frames.md), [Plan 04](04-resources-memory-and-sync.md), [Plan 05](05-shaders-pipelines-and-bindings.md)

## Goal

Make Metal's distinctive capabilities first-class in `mt` instead of reducing
the wrapper to indexed draws and Vulkan-like resource binding.

This module owns extension APIs and capability gates. It does not make every
device support every feature, and it does not force applications to use
extensions when a simpler core path is enough.

## Feature policy

Every extension must provide:

- a capability query;
- a descriptor that expresses its Metal-specific requirements;
- a creation/encoding API;
- clear unsupported-device errors;
- a fallback example when a useful fallback exists;
- native-handle access for advanced users.

The extension API may live under `mt::metal` when it cannot be expressed
meaningfully in the core API.

## 1. Mesh and object shaders

### Scope

- Object and mesh functions in render pipeline descriptions.
- Payload memory and object/mesh threadgroup configuration.
- Mesh output topology and output limits.
- `drawMeshThreadgroups` encoding.
- Meshlet buffers and payload-driven visibility.
- GPU culling and LOD selection hooks.
- Indexed/vertex fallback path.

### API sketch

```cpp
namespace mt::metal {

struct MeshDispatchDesc {
    Extent3D threadgroups;
    Extent3D threads_per_object_group;
    Extent3D threads_per_mesh_group;
};

Result<void> draw_mesh_threadgroups(
    RenderEncoder&, const MeshDispatchDesc&);

} // namespace mt::metal
```

The core renderer should understand that a mesh pipeline is a valid graphics
pipeline. Mesh dispatch must not be hidden behind a fake indexed draw.

### Fallback policy

If mesh shaders are unavailable:

- an application may select an indexed/vertex pipeline explicitly;
- the renderer may choose a declared fallback;
- the selected path must be observable in diagnostics/capabilities;
- mesh-only features must fail clearly when no semantic fallback exists.

## 2. Argument buffers

### Scope

- Typed argument-buffer layout descriptions.
- Argument encoder creation.
- Arrays of buffers, textures, and samplers.
- Material, scene, and instance tables.
- CPU update and GPU visibility rules.
- Nested argument buffers where supported.

Argument buffers are not a disguised descriptor-set API. Their layout,
encoding cost, array limits, and shader declarations should remain visible.

### API sketch

```cpp
struct ArgumentBufferLayout {
    std::vector<Binding> entries;
    uint32_t encoded_length;
};

class ArgumentBuffer {
public:
    Result<void> set_buffer(uint32_t index, const Buffer&, uint64_t offset);
    Result<void> set_texture(uint32_t index, const Texture&);
    Result<void> set_sampler(uint32_t index, const Sampler&);
    NativeHandle native_handle() const noexcept;
};
```

The binding module validates indices and resource kinds. This module adds
Metal-specific encoder behavior and capability handling.

## 3. Indirect command buffers and GPU-driven rendering

### Scope

- `MTLIndirectCommandBuffer` ownership and descriptor creation.
- GPU-generated render and compute commands where supported.
- Command-buffer execution from a render encoder.
- Visibility/culling result buffers.
- Forward+ and meshlet batching integration.

The plan must verify which indirect command types are available for the
deployment target and device. Do not advertise mesh indirect support merely
because ordinary indexed indirect draws work.

### API sketch

```cpp
namespace mt::metal {

class IndirectCommandBuffer {
public:
    Result<void> reset(RenderEncoder&);
    Result<void> execute(RenderEncoder&, uint32_t count);
    NativeHandle native_handle() const noexcept;
};

} // namespace mt::metal
```

GPU-generated command data must remain alive until execution completes.

## 4. Tile shaders and tile-local storage

### Scope

- Tile function loading and pipeline creation.
- Tile threadgroup memory/imageblock descriptors.
- Tile pass encoding.
- Raster-order synchronization where available.
- Memoryless color/depth attachments.
- Bandwidth-conscious resolve/store policies.

Tile rendering is an explicit extension, not a hidden behavior of ordinary
fragment or compute encoders. A `TilePassDesc` should state its attachment
and storage assumptions.

### Constraints

- Only use memoryless attachments when data is not needed after the pass.
- Validate tile memory and threadgroup limits.
- Provide an ordinary render/compute alternative for examples where useful.
- Do not emulate tile shaders by silently changing a normal render pass.

## 5. SIMD-group and Apple GPU execution

Expose device and pipeline information needed to make execution choices:

- SIMD-group width;
- thread execution width;
- maximum threadgroup size;
- static/dynamic threadgroup memory;
- occupancy-related limits exposed by Metal;
- supported SIMD-group and matrix operations.

Most SIMD operations are shader-language facilities rather than C++ encoder
methods. The C++ layer should provide capability and pipeline metadata, while
MSL contains the specialized code.

## 6. Ray tracing and intersection functions

Add as a separate optional module:

- acceleration-structure descriptors and build/update commands;
- geometry and instance descriptions;
- intersection functions;
- function tables and specialized libraries;
- ray-generation and dispatch operations;
- synchronization and lifetime rules.

The baseline renderer must work without ray tracing. Ray tracing should be
enabled only after `DeviceCapabilities` confirms support and the requested
pipeline is validated.

## 7. Profiling, counters, and debugging

Provide optional APIs for:

- command-buffer labels and debug groups;
- GPU counter sample buffers;
- timestamps and pass timing;
- Metal capture markers;
- native GPU capture integration where appropriate.

Profiling must not alter resource ownership or command ordering in release
builds.

## Cross-feature capability model

Use feature-specific capability records rather than a single boolean when a
feature has meaningful limits:

```cpp
struct MeshShaderCapabilities {
    bool supported;
    uint32_t max_object_threads;
    uint32_t max_mesh_threads;
    uint32_t max_mesh_vertices;
    uint32_t max_mesh_primitives;
    uint32_t payload_bytes;
};
```

The same pattern applies to argument-buffer limits, tile memory, ray-tracing
features, and ICB command types.

## Implementation steps

1. Add feature records to `DeviceCapabilities`.
2. Implement mesh/object pipeline creation and dispatch.
3. Implement argument-buffer layout and encoding.
4. Implement ICB creation and a GPU-culling example.
5. Implement tile/memoryless pass descriptors on a supported device.
6. Add SIMD/matrix capability metadata and MSL examples.
7. Add ray-tracing types behind a separate target or feature flag.
8. Add counters, labels, and capture examples.
9. Test every supported path and its declared fallback.

## Acceptance criteria

- Mesh/object shaders are usable through public C++ APIs.
- Argument buffers can represent material/scene tables without pretending
  they are Vulkan descriptor sets.
- GPU-generated indirect commands can drive a documented rendering path.
- Tile and memoryless features are explicit and capability-gated.
- Ray tracing is optional and does not contaminate baseline initialization.
- Device-specific limits are visible to applications and pipeline planning.
- Unsupported features produce actionable errors rather than silent downgrades.

