# Plan 21 — Asset-pipeline integrations

**Status:** proposed — optional integration
**Scope:** importers, texture files, conversion, and serialization
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 12, 16, and 18

## Goal

Let applications bring external content into the typed scene and GPU asset
model without making any importer, codec, or serialization format part of
the Metal wrapper core.

## Integration work owned by this plan

- Assimp or another explicitly selected geometry importer.
- Texture-file loading and conversion into documented `mt::Texture` upload
  descriptors.
- Asset conversion for indexed meshes, curves, materials, skeletons, and
  optional meshlet/LOD representations.
- Versioned scene/material/mesh serialization.
- Import diagnostics, source metadata, coordinate-system policy, color-space
  policy, and capability-aware conversion.
- Standalone importer/loader examples and fixtures.

## Integration boundary

- Importers produce Plan 16 value types; they do not create hidden devices,
  queues, surfaces, or command buffers.
- File codecs and import libraries are optional targets with independent
  licensing and version policies.
- Serialization is a content contract, not a replacement for GPU resource
  lifetime or synchronization. Loading still uses Plan 12's explicit upload
  and retirement paths.
- Texture format, mip, color-space, and compression decisions are recorded
  rather than silently changing at upload time.

## Implementation steps

1. Define normalized geometry, material, texture, coordinate, and color-space
   interchange values.
2. Add an importer adapter with explicit ownership and diagnostics.
3. Add texture-file loaders and conversion policies.
4. Add versioned serialization and compatibility/migration behavior.
5. Add meshlet/LOD conversion only when the target device/content profile
   requests it.
6. Add independent command-line or C++ consumer examples and fixtures.

## Tests

- Import fixtures for indexed meshes, curves, materials, textures, and
  malformed/unsupported files.
- Deterministic conversion tests for coordinates, winding, normals, tangents,
  color spaces, mip policy, and texture formats.
- Serialization round-trip and version-migration tests.
- GPU upload tests proving imported resources use explicit Plan 12 lifetime
  and synchronization behavior.
- Build-isolation tests with importers/codecs disabled.

## Acceptance criteria

- External content can be converted into Plan 16 scene values without
  importing third-party headers into the core public API.
- Import and conversion failures identify source, field, and capability.
- Serialized assets have a versioned, documented compatibility policy.
- Core/offscreen consumers remain buildable without any content dependency.

## Non-goals

- Defining a universal asset format for all applications.
- Hiding storage modes, synchronization, or GPU lifetime behind an importer.
- Python bindings, GUI/font integration, or external IOSurface/media
  resources.
