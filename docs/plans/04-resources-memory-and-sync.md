# Plan 04 — Resources, memory, uploads, and synchronization

**Status:** implemented — Swift-first implementation; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** [Plan 02](02-device-and-capabilities.md), [Plan 03](03-commands-surfaces-and-frames.md)

## Goal

Provide typed Metal resource wrappers with storage and synchronization policies
that match macOS hardware instead of copying Vulkan's memory model.

The default API should use explicit typed objects. A name-based registry may be
added for vkkk-style applications, but it must not be required by the core.

## Responsibilities

- Buffers and buffer slices.
- Textures, texture views, samplers, and texture arrays.
- Render targets, depth/stencil attachments, MSAA, and resolve targets.
- Heaps and optional aliasing.
- Shared/private/managed/memoryless storage policy.
- Upload, readback, and dynamic-buffer allocation.
- Resource usage and hazard declarations.
- Fences, events, and command completion integration.

## Non-goals

- Shader binding layouts; Plan 05 owns the contract.
- Material and scene ownership; Plan 08 owns that.
- A global string-keyed resource map.
- Assuming every Mac has unified memory.

## Resource types

### Buffers

Implement:

- immutable GPU buffers;
- CPU-visible shared buffers;
- managed buffers where required by device/storage mode;
- private GPU-only buffers;
- dynamic/ring-buffer slices;
- indirect-command buffers;
- readback buffers.

Illustrative API:

```cpp
struct BufferDesc {
    uint64_t size;
    BufferUsage usage;
    StorageMode storage;
    CpuCacheMode cpu_cache;
    HazardMode hazard;
    std::string_view label;
};

class Buffer {
public:
    uint64_t size() const noexcept;
    Result<BufferMapping> map(MapMode);
    Result<void> upload(std::span<const std::byte>, uint64_t offset = 0);
    NativeHandle native_handle() const noexcept;
};
```

`BufferMapping` must document whether writes require an explicit
`didModifyRange` or equivalent synchronization for managed storage.

### Textures

Support:

- 1D, 2D, 3D, array, cube, and cube-array textures;
- color, depth, stencil, and depth/stencil formats;
- mip levels and array slices;
- usage flags for render, shader read, shader write, and blit;
- MSAA textures and resolve targets;
- texture views where Metal supports the requested reinterpretation;
- readback to a CPU-visible buffer.

Validate dimensions, format, usage, sample count, and device limits at
creation. Do not expose a format as supported only because it exists in a
portable enum.

### Samplers

Wrap address modes, min/mag/mip filters, compare functions, LOD range,
anisotropy, and reduction behavior supported by the target SDK.

### Render and depth attachments

`RenderTarget` and `DepthAttachment` should be descriptive views over textures,
not separate hidden allocations unless a factory is explicitly requested.

Support:

- color attachment sets;
- depth-only and stencil-only passes;
- MSAA plus resolve;
- memoryless attachments when supported;
- resize/recreate helpers for window-relative targets;
- readback only for targets that were stored.

## Metal storage policy

The wrapper must make storage policy explicit:

| Storage mode | Intended use |
| --- | --- |
| Shared | CPU/GPU shared updates, small dynamic data, unified-memory fast paths |
| Private | GPU-only resources and large static data |
| Managed | macOS devices requiring separate CPU/GPU synchronization |
| Memoryless | transient tile-local attachments that never need external storage |

The policy is a hint validated against the device. An application can request
a mode, but the wrapper must reject unsupported combinations rather than
silently changing CPU visibility or lifetime behavior.

Use private resources plus blit uploads when that is faster. Do not impose a
staging copy on unified-memory devices when direct shared writes are the
appropriate Metal path.

## Upload and readback

Implement explicit operations:

- `upload_buffer`;
- `upload_texture`;
- `copy_buffer`;
- `copy_texture`;
- `generate_mipmaps`;
- `readback_buffer`;
- `readback_texture`;
- `read_render_target_pixel`.

Large asynchronous uploads should be encoded through a blit encoder supplied
by the application or an upload helper that owns a documented queue. The core
must not secretly create unbounded command queues.

Provide a ring allocator for frequently updated uniform/parameter data:

- frame-relative allocation;
- alignment from device limits;
- no reuse until the associated command buffer completes;
- optional shared or private backing.

## Hazard and synchronization model

Metal may provide automatic hazard tracking, but the wrapper still needs an
explicit model for:

- resources used by multiple encoders;
- private resources copied from upload buffers;
- cross-command-buffer and cross-queue visibility;
- managed-storage synchronization;
- fences and shared events;
- command-buffer completion.

Expose synchronization only where it has a real Metal mapping:

```cpp
class Fence;
class SharedEvent;

void wait_for(const Fence&);
void signal(Fence&);
```

Avoid presenting Vulkan-style pipeline barriers as if they were required for
every Metal pass. Resource usage declarations should guide validation and
hazard behavior without forcing needless barriers.

## Heaps and aliasing

Add heaps after basic resources work:

- heap descriptor with size, storage, hazard, and type;
- resource creation from a heap;
- predictable lifetime and aliasing rules;
- residency/size diagnostics;
- no aliasing while an earlier command buffer can still reference the resource.

Heap support is a Metal-native optimization, not a prerequisite for ordinary
resource creation.

## Optional resource registry

For higher-level vkkk-style code, provide a separate registry:

```cpp
class ResourceRegistry {
public:
    Result<void> insert(std::string name, Buffer);
    Buffer* find_buffer(std::string_view name);
    Result<void> remove(std::string_view name);
};
```

The registry must:

- be explicitly owned by the application or renderer;
- define duplicate-name behavior;
- not hide resource lifetime from command buffers;
- support typed lookup;
- remain optional for direct Metal-style users.

## Implementation steps

1. Add buffer and buffer-view descriptors.
2. Add texture, sampler, and attachment descriptors.
3. Implement shared/private/managed storage and mapping rules.
4. Implement upload and readback helpers.
5. Implement dynamic/ring buffers.
6. Add render-target, depth, MSAA, resolve, and memoryless paths.
7. Add hazard declarations and completion-safe lifetime tests.
8. Add heaps and aliasing behind capability/size validation.
9. Add the optional typed resource registry.

## Acceptance criteria

- A consumer can create and use typed buffers, textures, samplers, depth
  attachments, render targets, and readback resources.
- Shared/private/managed behavior is documented and tested on available
  devices.
- Memoryless attachments are used only when the target does not require
  storage outside the pass.
- Uploads and readbacks do not create hidden unbounded queues.
- Dynamic-buffer slices remain alive until their command buffer completes.
- Resource usage errors identify the resource, encoder, and invalid operation.
- String-keyed resources are optional and do not define core ownership.

## Implementation in this slice

Implemented in Swift:

- explicit storage, cache, hazard, usage, texture-type, sampler, and resource
  descriptor values;
- device-created buffers, buffer slices, dynamic shared-buffer allocation,
  textures, texture views, samplers, heaps, fences, and shared events;
- shared/managed/private/memoryless validation at resource creation;
- CPU-visible buffer upload/readback and managed-buffer modification marking;
- CPU-visible base-level 2D texture upload/readback;
- render-target and depth/stencil attachment wrappers, including sample-count
  and format validation;
- explicit buffer/texture resource declarations on render and compute
  encoders;
- blit buffer/texture copies, managed-resource synchronization, mip generation,
  and fence operations;
- command-buffer shared-event signal/wait operations;
- organized C++ facade headers and Swift/C++ API-shape tests.

Plan 12 adds private-resource staging helpers, full subresource-region
upload/readback, completion-aware ring-buffer reuse, resource
retirement/versioning, and the optional typed string-keyed registry. Private
resources must be populated and read back through explicit blit
resources/encoders rather than hidden queues. Build and runtime verification
remains intentionally pending on a Metal-capable macOS machine; evidence is
tracked in
[Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).

