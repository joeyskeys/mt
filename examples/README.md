# Examples and validation consumers

`consumer_smoke` is the always-on C++ package-shape example. It includes the
public umbrella header, links `mt::mt`, and prints the library version without
requiring a window or a Metal device.

`runtime_smoke` is the capability-aware C++ validation launcher. Pass one of
the names below as its first argument; it records the required native path and
fallback, enumerates the device, and submits an ownership smoke command
buffer. It reports whether each example's native capability path is available
and prints the documented fallback when it is not. The installed consumer
also invokes the packaged headless clear/readback fixture; the Swift
offscreen validation suite covers the remaining Metal resources without
adding a host dependency to the examples.

The runtime examples below are planned validation entry points. They should be
enabled only on a Metal-capable machine and must keep queue, command-buffer,
surface, and frame ownership in the application:

| Example | Required path |
| --- | --- |
| `device_info` | Device enumeration and capability reporting |
| `offscreen_triangle` | Offscreen render, commit, and readback |
| `window_triangle` | Optional AppKit/CAMetalLayer adapter |
| `indexed_mesh` | Resources, depth, textures, and renderer |
| `compute_image` | Compute plus blit/readback |
| `mesh_triangle` | Mesh/object shader capability |
| `argument_buffer_materials` | Argument-buffer capability |
| `gpu_culling` | ICB/indirect capability |
| `tile_pass` | Tile/memoryless capability |
| `forward_plus` | Renderer and light-clustering path |
| `viewport_picking` | Viewport phases and ID readback |
| `external_iosurface` | Optional imported-resource contract |
| `python_import` | Optional selected-interpreter module import |

The machine-readable requirements and fallback descriptions are maintained in
[`validation-matrix.json`](validation-matrix.json). `runtime_smoke` is the
shared entry point while the matrix keeps each eventual example contract
explicit and prevents unsupported native paths from being reported as passed.

The installed consumer under `tests/consumer/installed` is the canonical
external-project check. It is intentionally separate from this example list.

## Optional native window consumers

When the corresponding options are enabled, the Swift examples demonstrate
the application-owned frame loop:

```sh
cmake -S . -B build-host \
    -DMT_BUILD_APPKIT=ON \
    -DMT_BUILD_MTKVIEW=ON \
    -DMT_BUILD_HOST_EXAMPLES=ON
```

- `mt-example-appkit-window` uses `AppKitWindowHost` and a borrowed
  `CAMetalLayer`.
- `mt-example-mtkview-window` uses `MTKViewWindowHost` and an application
  timer as the frame loop.

Both examples only clear and present a drawable. They do not make the core
own a window, queue, renderer, or event loop. See
[`docs/integrations/native-host-contract.md`](../docs/integrations/native-host-contract.md)
for lifetime, resize, drawable-loss, scale, and input rules.

## Optional GUI and text consumers

GUI/text examples are disabled unless their integration targets are explicitly
enabled:

```sh
cmake -S . -B build-gui-text \
    -DMT_BUILD_APPKIT=ON \
    -DMT_BUILD_IMGUI=ON \
    -DMT_BUILD_TEXT=ON \
    -DMT_BUILD_GUI_TEXT_EXAMPLES=ON
```

- `mt-example-imgui-boundary` demonstrates initialization, input/value
  translation, frame phases, and application-owned command-buffer boundaries.
  It does not bundle ImGui or pretend that an ImGui draw list was rendered.
- `mt-example-text-atlas` exercises CoreText glyph lookup, deterministic
  atlas construction, layout, and text-mesh generation.

The FreeType target is a separate value bridge. A consumer owns FreeType and
passes rasterized glyph bitmaps to `mt-freetype`; no FreeType library or header
is linked into the core or CoreText targets.

## Optional asset-pipeline consumer

Enable the dependency-free asset integration and its value-only example:

```sh
cmake -S . -B build-assets \
    -DMT_BUILD_ASSET_PIPELINE=ON \
    -DMT_BUILD_ASSET_PIPELINE_EXAMPLES=ON
```

`mt-example-asset-pipeline` loads a P5 fixture, converts it into an explicit
asset value, and exercises versioned serialization. It does not bundle an
importer, create a device, or submit GPU work. External Assimp/image-codec
consumers should pass normalized values through `mt/asset_pipeline.hpp`.

## Optional language and external-resource consumers

Enable the IOSurface boundary as a separate target:

```sh
cmake -S . -B build-external \
    -DMT_BUILD_EXTERNAL_RESOURCES=ON
```

`mt-example-external-resources` validates an IOSurface descriptor and records
an explicit shared-event policy. It does not create, own, or synchronize a
producer's surface.

The Python example is source-only and is built as an optional custom target
when `MT_BUILD_PYTHON=ON`. Select the same interpreter used for the extension:

```sh
cmake -S . -B build-python \
    -DMT_BUILD_PYTHON=ON \
    -DMT_PYTHON_EXECUTABLE="$CONDA_PREFIX/bin/python" \
    -DMT_PYTHON_ROOT="$CONDA_PREFIX"
PYTHONPATH=/path/to/mt/install/lib \
    "$CONDA_PREFIX/bin/python" examples/python_smoke.py
```

See
[`docs/integrations/language-resource-contract.md`](../docs/integrations/language-resource-contract.md)
for ownership, GIL, synchronization, format validation, and fallback rules.

