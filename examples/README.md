# Examples and validation consumers

`consumer_smoke` is the always-on C++ package-shape example. It includes the
public umbrella header, links `mt::mt`, and prints the library version without
requiring a window or a Metal device.

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

The installed consumer under `tests/consumer/installed` is the canonical
external-project check. It is intentionally separate from this example list.

