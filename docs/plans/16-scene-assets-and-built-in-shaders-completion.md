# Plan 16 — Scene, assets, and built-in shaders completion

**Status:** proposed — wrapper-owned scene/render-data follow-up
**Scope:** graphics wrapper scene, GPU asset, material, and shader content
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 12–14

## Goal

Complete the reusable scene and render-data layer that sits between application
content and the renderer. This plan owns typed GPU-facing data structures,
materials, lights, procedural geometry, and built-in shader families. File
importers, serialization formats, and other content-pipeline dependencies are
integration work covered by Plan 21.

## Deferred work owned by this plan

- `MeshView`, curve data, meshlet payloads, LOD/culling metadata, and retention
  of indexed and meshlet representations.
- Versioned scene `sync_to_gpu` tracking and completion-backed retirement of
  replaced or removed GPU meshes.
- Complete material parameter and argument-buffer tables.
- Texture ownership, sampler fallback policy, and persistent material/pipeline
  cache integration.
- Forward+ cluster data generation and shadow-resource ownership.
- Built-in Phong, clustered Phong, PBR, shadow, billboard, text,
  mesh-visualization, and light-clustering MSL families.
- Matching C++/MSL layout metadata, entry points, defaults, and capability
  requirements for every built-in shader.

## Metal-native design

- CPU scene ownership remains separate from device resource ownership.
  Synchronization produces versioned GPU resources and retires old versions
  only after dependent command buffers complete.
- Meshlets are an optional native representation, not a requirement for
  ordinary indexed geometry. The scene records both representations when
  needed for fallback.
- Material tables use Metal argument buffers when supported and explicit slots
  otherwise; the material API reports which path was selected.
- Built-in shader families remain MSL and use explicit layout metadata. They
  must not assume that all devices support mesh shaders, tile shaders, ray
  tracing, or argument-buffer tiers.

## Implementation steps

1. Add typed mesh views, curve/meshlet data, LOD metadata, and lifetime
   ownership independent of file importers.
2. Add versioned scene-to-GPU synchronization and completion-backed resource
   retirement.
3. Complete material texture/sampler/parameter tables and integrate Plan 13
   binding/reflection validation.
4. Add light-cluster and shadow data contracts consumed by Plan 15.
5. Implement and package the remaining built-in shader families with fallback
   variants and capability metadata.
6. Add deterministic procedural fixtures for indexed, instanced, meshlet,
   material, light, shadow, and text geometry.

## Tests

- CPU scene mutation, versioning, mesh-view, curve, meshlet, LOD, and
  material-table tests.
- Device-guarded upload/synchronization tests, including replacement and
  retirement while work is in flight.
- C++/MSL size, alignment, binding, entry-point, and default-value tests for
  every built-in shader family.
- Capability tests for argument-buffer, mesh, tile, and fallback shader
  variants.
- Renderer integration tests for clustered lights, shadow resources, and
  material selection.

## Acceptance criteria

- A scene can retain indexed and native mesh representations and choose one
  without losing stable object identity.
- GPU scene synchronization is versioned, completion-safe, and observable.
- Materials and lights can be consumed by both baseline and native Metal
  renderer paths.
- The built-in shader library covers the documented families with validated
  fallback metadata.

## Non-goals

- Assimp or other file importers, texture-file codecs, and serialization
  formats; see Plan 21.
- Host windows, GUI, font-loading frameworks, Python, or external resources.
- Forcing every scene to use meshlets, argument buffers, or Forward+.
