# Metal capability matrix

This file is a result template for Plan 11. Record observations from a
Metal-capable machine rather than inferring support from CPU architecture.

## Verification record

For every run, record:

- macOS version;
- Xcode/SDK and Swift compiler version;
- `mt` commit/build configuration;
- device name, registry ID, device type, and unified-memory flag;
- whether Metal API validation was enabled;
- test/example name and result;
- diagnostic output for unavailable or failed capabilities.

## Capabilities

### Basic Metal

- Minimum path: device, queue, command buffer, buffers, textures, render and
  compute encoders.
- Native result:
- Tests/examples:

### Mesh shaders

- Minimum path: indexed/vertex fallback.
- Native path: object/mesh/fragment pipeline and mesh dispatch.
- Device result:
- Fallback result:
- Tests/examples:

### Argument buffers

- Minimum path: direct resource slots.
- Native path: argument-buffer material/resource tables.
- Tier/result:
- Tests/examples:

### Indirect command buffers

- Minimum path: CPU-encoded indirect draws where available.
- Native path: GPU-generated ICB commands.
- Command-type result:
- Tests/examples:

### Tile and memoryless rendering

- Minimum path: stored render pass.
- Native path: tile pipeline, imageblock/tile-local configuration, and
  memoryless attachments.
- Device result:
- Availability provenance (OS/SDK/family):
- Tests/examples:

### Ray tracing

- Minimum path: unavailable/omitted.
- Native path: acceleration structures, motion geometry, intersection
  function tables, and compute dispatch bindings.
- Device result:
- Availability provenance (OS/SDK/family):
- Build/refit/compaction result:
- Tests/examples:

### Counter sampling

- Minimum path: CPU/GPU timestamp hooks.
- Native path: counter-set enumeration, counter sample buffers, pass-boundary
  samples, polling, and shared-storage resolution.
- Device result:
- Availability provenance (OS/SDK/family):
- Tests/examples:

### SIMD-group and matrix features

- Minimum path: ordinary compute dispatch.
- Native path: family-gated SIMD-group and SIMD-group matrix shader paths.
- Device result:
- Availability provenance (OS/SDK/family):
- Observed width/tile limits (leave unknown when unmeasured):
- Tests/examples:

### Managed storage

- Minimum path: explicit synchronization.
- Native path: direct shared/private or unified-memory path.
- Device/result:
- Tests/examples:

### Renderer paths

- Minimum path: ordered indexed Forward passes.
- Native paths: Forward+ compute clustering, indirect commands, mesh/object
  submission, and GPU culling.
- Selected-path/fallback result:
- Cluster overflow and culling result:
- Pipeline-cache and persistent-statistics result:
- Tests/examples:

### Viewport picking

- Minimum path: RGBA8 ID pass, private-to-shared blit, polled readback.
- Native extensions:
- Resize/in-flight result:
- Tests/examples:

