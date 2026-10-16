# Plan 08 — Scene, assets, geometry, and built-in shaders

**Status:** proposed
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md), [Plan 04](04-resources-memory-and-sync.md), [Plan 05](05-shaders-pipelines-and-bindings.md), [Plan 07](07-renderer-layer.md)

## Goal

Provide the application-facing scene and asset layer corresponding to vkkk's
`Scene`, `DrawableMgr`, `LightMgr`, concepts, and built-in shader families.

This module owns CPU domain data and coordinates GPU uploads. It does not own
the Metal device globally or the host application's window.

## Responsibilities

- Scene objects and transforms.
- CPU meshes, mesh views, lines, points, curves, and meshlets.
- Drawable/asset management.
- GPU synchronization for scene resources.
- Materials and texture references.
- Light storage for Forward and Forward+.
- Built-in MSL and matching C++ data layouts.
- Optional imported/procedural geometry.

## Non-goals

- Low-level Metal resource ownership; Plan 04 owns that.
- Pipeline compilation; Plan 05 owns that.
- Renderer pass scheduling; Plan 07 owns that.
- Viewport feature lifecycle; Plan 09 owns that.
- Requiring Assimp or another importer in the core target.

## Scene model

Provide a CPU-side object table:

```cpp
struct SceneObject {
    std::string name;
    std::string mesh_name;
    Transform transform;
    MaterialHandle material;
    uint32_t visibility_mask;
};

class Scene {
public:
    Result<void> add_object(SceneObject);
    Result<void> remove_object(std::string_view name);
    SceneObject* find_object(std::string_view name);
    size_t object_count() const noexcept;
};
```

Names are useful at the scene/application layer. They must not imply that the
core Metal wrapper uses global string-keyed resource maps.

## Geometry types

Port the useful vkkk concepts:

- owning packed `Mesh`;
- non-owning `MeshView`;
- indexed and non-indexed vertices;
- `Lines`;
- `Points`;
- curves and procedural geometry;
- meshlet metadata and payload layout for mesh shaders.

Geometry descriptors should declare:

- vertex attributes and formats;
- stride and alignment;
- index type;
- primitive topology;
- optional per-instance attributes;
- meshlet bounds and payload information;
- CPU ownership and mutation policy.

The GPU representation should be created by a `DrawableManager` using Plan 04
resources and should remain independent from the CPU container's storage.

## Drawable manager

Responsibilities:

- load or create CPU geometry;
- add planes, cubes, spheres, lines, and other procedural primitives;
- look up/remove/clear geometry;
- upload or update GPU resources;
- retain both indexed and meshlet representations when needed;
- defer destruction until in-flight command buffers are safe.

Illustrative interface:

```cpp
class DrawableManager {
public:
    Result<void> load_mesh(std::string name, Mesh);
    Result<void> load_file(const std::filesystem::path&);
    Result<void> sync_to_gpu(Device&, UploadContext&);

    const Mesh* find_mesh(std::string_view) const;
    MeshGPU* find_gpu_mesh(std::string_view);
};
```

Imported assets should be an optional adapter, with Assimp or another
dependency isolated from the core scene types.

## Materials and textures

Define a material description that references:

- shader/pipeline family;
- scalar/vector parameters;
- texture and sampler handles;
- alpha/blend/depth policy;
- argument-buffer layout;
- required device capabilities.

Material instances should use argument buffers for large resource tables when
supported, but retain a direct-slot path for simple pipelines and debugging.

## Light manager

Store CPU light data by scene and renderer:

- directional lights;
- point lights;
- spot lights;
- shadow parameters;
- clustered-light limits and overflow state.

Upload paths should provide:

- frame uniform data;
- structured light buffers;
- cluster bounds/index buffers;
- renderer-specific storage without coupling the scene to one renderer.

## Built-in shader families

Provide MSL plus adjacent C++ layout types for:

- fixed-color geometry;
- Phong;
- clustered Phong/Forward+;
- PBR;
- directional shadows;
- mesh-shader line and face-normal visualization;
- billboards;
- text;
- light clustering compute.

Each family must document:

- entry points;
- bindings and argument-buffer layout;
- CPU/MSL struct sizes and alignment;
- required texture formats;
- required device capabilities;
- indexed/mesh fallback behavior;
- render and compute pass order.

Do not reuse GLSL layout assumptions. Add static checks or runtime validation
for every built-in buffer contract.

## Meshlet representation

Define an optional meshlet asset representation:

- vertex and primitive ranges;
- bounding sphere/cone;
- material and LOD references;
- object payload metadata;
- culling flags.

The asset layer may retain a conventional indexed mesh alongside meshlets so a
scene can run on devices without mesh shaders.

## Billboards and text

Provide data and rendering contracts for:

- camera-facing text billboards;
- glyph atlas or text texture references;
- per-instance transform/color;
- depth and overlay policy.

Actual font loading belongs in Plan 10 unless the library chooses a small
dependency-free glyph path.

## Lifetime and synchronization

- CPU scene mutation must not invalidate GPU data still used by a command
  buffer.
- `sync_to_gpu` must identify which resource versions changed.
- Removed objects and meshes are retired after completion, not immediately
  freed if referenced by in-flight work.
- Renderer-specific temporary buffers remain owned by the renderer.

## Implementation steps

1. Add CPU `Mesh`, `MeshView`, `Lines`, `Points`, and transform types.
2. Add `Scene` and named object operations.
3. Add `DrawableManager` with procedural geometry.
4. Upload indexed geometry through Plan 04.
5. Add materials, textures, and light storage.
6. Add built-in MSL/C++ layout pairs.
7. Add imported assets behind an optional target.
8. Add meshlet data and mesh-shader-aware synchronization.
9. Add billboard/text data paths.

## Acceptance criteria

- A scene can add, find, update, and remove named objects without global Metal
  state.
- Procedural meshes, lines, and points upload to GPU resources.
- CPU and GPU geometry lifetimes are safe across in-flight command buffers.
- Forward and Forward+ can consume shared camera, material, and light data.
- Built-in MSL layouts are validated against their C++ structs.
- Meshlet data coexists with an indexed fallback.
- Importer and font dependencies remain optional.

