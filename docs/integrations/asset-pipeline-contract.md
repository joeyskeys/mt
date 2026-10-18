# Asset-pipeline integration contract

Plan 21 is an optional content boundary. It converts application-owned
importer output into Plan 16 scene and render-data values without adding an
importer, codec, file format, or content dependency to `mt::mt`.

## Target boundaries

```text
mt::mt
└── mt::mt-asset-pipeline
    ├── normalized importer values
    ├── deterministic coordinate/material/texture conversion
    ├── versioned JSON asset documents
    └── optional P5/P6 fixture loader
```

`mt-asset-pipeline` depends only on `mt::mt` and Foundation. Assimp, image
codecs, USD, glTF, FBX, and other third-party libraries are not bundled or
linked. A consumer may decode with one of those libraries and pass the
resulting value packet to `AssetImporterAdapter` or `AssetTextureLoader`.

## Ownership and lifetime

- The application owns importer instances, file handles, decoder state,
  allocators, and source memory.
- `AssetDocument`, mesh, material, and texture values are copied snapshots.
  They do not retain importer handles or file mappings.
- `AssetTexture.upload(device:storageMode:usage:label:)` requires an
  application-owned `Device` and creates only the explicit texture resource.
  It does not create a queue, command buffer, surface, or frame loop.
- Private-resource transfers, completion tokens, and retirement remain the
  responsibility of the Plan 12 core lifetime APIs.

## Conversion policy

`AssetConversionPolicy` makes the potentially lossy choices explicit:

- source/target up and forward axes, handedness, and unit scale;
- automatic/preserved/reversed triangle winding;
- source/target color space and UV origin;
- texture format and mip policy;
- whether tangent and vertex-color channels should be retained in normalized
  values.

Plan 16's `MeshVertex` currently contains position, normal, and UV only.
Conversion therefore returns the normalized asset mesh and emits a warning
when tangent or vertex-color channels cannot be represented by that core
vertex layout. It does not silently discard those channels.

The baseline texture loader supports binary P5/P6 images with 8-bit channels.
Other formats must enter through `AssetTexture` decoded values. Format,
origin, color-space, and mip decisions are recorded in the returned value or
diagnostics; no implicit codec or GPU mip-generation dependency is added.

## Serialization policy

`AssetSerializer` writes a deterministic sorted-key JSON document with schema
version `1.1`. Documents with a newer major or minor version are rejected.
Unversioned documents and older minor versions are accepted through an
observable migration result and upgraded to the current minor version.
Major-version changes require an explicit future migration implementation.

Serialization is a content contract only. It does not serialize live Metal
objects, command buffers, completion tokens, device handles, or private
resource state.

## Diagnostics and threading

Importers and conversion operate on caller-provided values and are safe to
schedule when the application serializes access to those values. No global
registry or hidden worker queue is created. Every failure identifies a source,
field, diagnostic code, and severity where the API can provide that context.
Warnings represent lossy conversion or unsupported color-space behavior;
errors prevent a value from being accepted.

Enable the integration explicitly:

```text
MT_BUILD_ASSET_PIPELINE=ON
```

The generated C++ facade is `mt/asset_pipeline.hpp`; it is intentionally not
included by `mt/mt.hpp`.
