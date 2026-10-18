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
- Native extensions: optional depth32-float and RGBA32-float normal
  attachments, deterministic scene/vertex IDs, and memoryless/tile/mesh
  capability selection with explicit baseline fallback.
- Overlap path: fragment-atomic linked-list A-buffer with configurable
  nodes-per-pixel, completion-gated CPU traversal, and explicit overflow
  reporting.
- Tile/mesh picking must remain reported as `resourcesUnavailable` until a
  native picking pipeline has the required tile/mesh resources; it must not
  be reported as selected while recording the baseline raster path.
- Selected acceleration path/fallback reason:
- Selected picking path/fallback reason:
- A-buffer hit count/overflow result:
- Depth/normal readback result:
- Resize/in-flight result:
- Tests/examples:

### Scene, materials, and built-in shaders

- Indexed representation and optional meshlet representation:
- Versioned GPU synchronization and retirement result:
- Material binding path (direct slots or argument buffers):
- Forward+ cluster and shadow-resource result:
- Built-in shader families and indexed fallbacks:
- Tests/examples:

### Native host integrations

- AppKit/CAMetalLayer adapter result:
- MTKView adapter result:
- Retina scale and drawable-size result:
- Drawable unavailable/resize recovery result:
- Presentation and application-owned frame-loop result:
- Input translation result:
- GLFW/Qt status: not enabled until a concrete native-layer ownership
  contract and consumer are supplied.
- Tests/examples:

### GUI and text integrations

- ImGui version/initialization and frame-phase result:
- ImGui input translation and external-renderer boundary:
- CoreText font/glyph/Unicode fallback result:
- Atlas dimensions, sampler, texture upload, and text-mesh result:
- FreeType value-bridge result and external `FT_Face` ownership:
- Optional-target/core dependency-isolation result:
- Tests/examples:

