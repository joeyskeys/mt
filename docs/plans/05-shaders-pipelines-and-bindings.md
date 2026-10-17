# Plan 05 — MSL, shader libraries, pipelines, and bindings

**Status:** implemented — Swift-first implementation; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** [Plan 01](01-build-and-cpp-abi.md), [Plan 02](02-device-and-capabilities.md), [Plan 04](04-resources-memory-and-sync.md)

## Goal

Build a Metal-native shader and pipeline system based on MSL and metallib,
while keeping CPU/MSL resource layouts explicit and verifiable.

The wrapper must not require GLSL/SPIR-V or emulate Vulkan descriptor sets.
Applications may add a separate cross-compilation tool later, but Metal's
native shader language is the primary input.

## Responsibilities

- MSL source and precompiled metallib loading.
- Shader library and function lookup.
- Function constants and specialization.
- Render, mesh, compute, and tile pipeline creation.
- Vertex, raster, depth/stencil, blend, and attachment state.
- Explicit binding layouts and argument-buffer metadata.
- Pipeline reflection and validation.
- Pipeline caching and optional binary archives.
- Reproducible shader build integration.

## Non-goals

- GLSL/SPIR-V compatibility in the core.
- Automatic descriptor-set emulation.
- Material ownership; Plan 08 uses this module.
- GPU-driven command encoding; Plan 06 consumes pipeline metadata.

## Shader source and packaging

Support two input paths:

1. **Precompiled metallib** for applications and release packages.
2. **MSL source compilation** for development and examples.

The build system should provide a helper that:

- compiles `.metal` source with the selected deployment target;
- produces a named `.metallib`;
- records source and SDK metadata;
- fails with diagnostics tied to the source file;
- installs or packages the library with the C++ target.

Runtime source compilation should be optional. A production application should
not need an Xcode installation or runtime compiler to load its shaders.

The installed CMake helper is used from a consuming project like this:

```cmake
find_package(mt CONFIG REQUIRED)

mt_add_metallib(my_shaders
    SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/shaders/main.metal"
    INSTALL_DESTINATION share/my_app/shaders
)
add_dependencies(my_app my_shaders)
```

The helper emits one AIR file per source and links them into a `.metallib`
with the selected SDK and deployment target. It is a packaging/build helper;
the wrapper's runtime source-compilation path remains useful for development
and diagnostics.

## Public object model

Suggested types:

```cpp
class ShaderLibrary {
public:
    Result<ShaderFunction> function(std::string_view name);
    Result<ShaderFunction> specialized(
        std::string_view name, const FunctionConstants&);
};

class RenderPipeline {
public:
    const RenderPipelineInfo& info() const noexcept;
    NativeHandle native_handle() const noexcept;
};

class ComputePipeline {
public:
    uint32_t thread_execution_width() const noexcept;
    uint32_t max_threads_per_threadgroup() const noexcept;
};
```

Creation should be owned by `Device` or a separate `PipelineFactory`, not by a
global registry:

```cpp
Result<RenderPipeline> device.create_render_pipeline(
    const RenderPipelineDesc&);
Result<ComputePipeline> device.create_compute_pipeline(
    const ComputePipelineDesc&);
```

## Pipeline categories

### Vertex/fragment render pipeline

Validate:

- vertex function and fragment function;
- vertex descriptor;
- primitive topology and raster state;
- color attachment formats and blending;
- depth/stencil format and state;
- sample count;
- function constants;
- resource binding metadata.

### Object/mesh/fragment pipeline

Add the Metal mesh-shader-specific fields:

- object function and mesh function;
- fragment function;
- payload memory length;
- object and mesh threadgroup sizes;
- mesh output limits;
- capability requirement;
- fallback association, if one exists.

A future built-in mesh-shader example is the first test case for this path.

### Compute pipeline

Expose:

- thread execution width;
- maximum threads per threadgroup;
- static threadgroup memory;
- function constants;
- indirect-dispatch compatibility;
- SIMD-group-related metadata when available.

### Tile pipeline

Tile functions and tile-specific state belong to the native extension module,
but the base shader system must be able to load and validate them.

## Binding model

Metal resources are bound through explicit buffer, texture, sampler, and
argument-buffer indices. Define an `mt::BindingLayout` that records:

- resource name;
- resource kind;
- stage visibility;
- index;
- array length;
- data layout and alignment;
- argument-buffer nesting;
- optional update frequency.

The layout is application-owned metadata. Reflection validates that the
compiled Metal functions agree with it; reflection is not the only source of
truth.

Example:

```cpp
struct Binding {
    std::string name;
    BindingKind kind;
    ShaderStage stages;
    uint32_t index;
    uint32_t array_length;
};

struct BindingLayout {
    std::vector<Binding> entries;
};
```

Do not create a fake `DescriptorSet` abstraction unless it adds real value for
the higher-level renderer. Direct slots and argument buffers should remain
visible.

## Parameter and “push constant” equivalent

Metal has no Vulkan push-constant object. Implement a `ParameterBlock` using
one of:

- `set*Bytes` for small transient values;
- a dynamically allocated uniform-buffer slice;
- inline data in an argument buffer.

The choice should be encoded by the block's update policy and device limits.
The public API must not promise a fixed Vulkan-style byte limit.

## Reflection and diagnostics

At pipeline creation, validate:

- function existence;
- stage compatibility;
- binding indices and types;
- buffer/texture/sampler usage;
- threadgroup memory and thread limits;
- attachment formats and sample count;
- mesh payload/output limits;
- function-constant specialization.

Diagnostics should include function names, pipeline label, binding name/index,
and the relevant native Metal error.

## Pipeline caches

Implement in stages:

1. In-memory cache keyed by descriptor and shader-library identity.
2. Optional Metal binary archive integration.
3. Persistent cache format with SDK/device/version invalidation.

Never reuse a pipeline across incompatible device capabilities or attachment
formats.

## Built-in shader layout rules

Built-in shader modules must colocate:

- C++ parameter structs;
- MSL structs;
- binding indices;
- alignment/static-size checks;
- shader entry-point names;
- required capabilities.

Metal's data layout rules are the source of truth for the MSL side. Do not
assume a Vulkan/GLSL std140 or std430 layout is automatically identical.

## Implementation steps

1. Add shader-library loading from metallib.
2. Add function lookup and error diagnostics.
3. Add render and compute pipeline descriptors.
4. Add vertex/fragment pipeline creation and reflection validation.
5. Add function constants and specialization.
6. Add mesh/object pipeline creation using a planned mesh-shader example.
7. Add explicit binding layouts and parameter blocks.
8. Add MSL build/package helpers.
9. Add pipeline caching and binary-archive support.
10. Leave tile-specific creation available for Plan 06.

## Acceptance criteria

- A C++ application can load a metallib without Swift or `MTKView`.
- Vertex/fragment and compute pipelines can be created and validated.
- An object/mesh/fragment example is represented by a reusable pipeline
  description.
- MSL binding indices are explicit and reflection catches mismatches.
- Function constants and parameter updates work without Vulkan push constants.
- Pipeline cache entries are invalidated for incompatible devices or formats.
- Release packaging can ship precompiled metallib without runtime compilation.

## Implementation in this slice

Implemented in Swift:

- MSL source and precompiled metallib loading through `Device`;
- named `ShaderLibrary` and `ShaderFunction` wrappers, including function
  enumeration, stage inspection, diagnostics, and function-constant
  specialization;
- `BindingLayout` metadata with duplicate-slot validation and
  `PipelineReflection` checks against Metal argument reflection;
- render pipeline descriptors for vertex/fragment and capability-gated
  object/mesh/fragment pipelines, including vertex descriptors, raster state,
  blending, attachment formats, sample counts, and indirect-command support;
- compute pipeline descriptors with threadgroup-size metadata;
- direct render/compute pipeline and resource-slot binding on the focused
  encoders;
- a small `ParameterBlock` for Metal's inline `set*Bytes` path. Larger
  parameter data should use Plan 04 buffer slices;
- C++ facade headers and API-shape tests under `include/mt/` and
  `tests/unit/shaders/`;
- a CMake `mt_add_metallib()` helper for reproducible `xcrun metal` and
  `xcrun metallib` packaging, installed with the CMake package.

The public C++ surface remains generated from the Swift module. The
source-controlled headers only include the generated aliases and do not
duplicate Metal ownership or implementation logic.

## Follow-up ownership

- Plan 13 implements the persistent/in-memory pipeline caches, device/SDK
  invalidation, Metal binary archives, dynamic-library composition, full
  argument-buffer tables, stronger reflection validation, and depth/stencil
  state objects. Runtime verification remains tracked by Plan 18.
- The dedicated tile-pipeline extension belongs to
  [Plan 14 — Metal-native capabilities completion](14-metal-native-capabilities-completion.md).
- Material parameter tables belong to Plan 16.
- The built-in mesh/object-shader MSL fixture is implemented by Plan 13;
  runtime coverage belongs to
  [Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).

Build, C++ ABI, MSL compilation, and runtime verification are intentionally
pending on a Metal-capable macOS machine. Package and runtime evidence is
tracked in Plan 18.

