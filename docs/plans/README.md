# `mt` module plans

These plans decompose [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
into implementation-sized modules. They describe a Swift-first Metal library
with a generated C++ interface, not a Vulkan compatibility layer.

## Design rules shared by every module

- The core ownership graph is `Device → CommandQueue → CommandBuffer →
  Encoder`.
- There is no required global `mt::Context`. A `Frame` or
  `FrameScheduler` is an optional convenience for drawable-based applications.
- Public C++ access is generated from a constrained Swift API. Swift, AppKit,
  `MTKView`, and Objective-C protocol types stay behind the module/header
  boundary.
- Metal features are exposed when supported instead of being removed to match
  another API. Capability checks and explicit fallbacks are required.
- Typed handles and explicit references are the default. Name-based registries
  belong in an optional higher-level module.
- Every module must document ownership, threading, error behavior, and its
  native Metal mapping.

## Implementation order

| Order | Plan | Module | Depends on |
| --- | --- | --- | --- |
| 0 | [Overview](00-overview.md) | Boundaries, conventions, and milestones | — |
| 1 | [Build and C++ ABI](01-build-and-cpp-abi.md) | Swift target, generated header, and package | — |
| 2 | [Device and capabilities](02-device-and-capabilities.md) | Swift Metal objects exposed to C++ | 1 |
| 3 | [Commands and surfaces](03-commands-surfaces-and-frames.md) | Command buffers, encoders, drawables, frames | 1, 2 |
| 4 | [Resources and synchronization](04-resources-memory-and-sync.md) | Buffers, textures, heaps, uploads, hazards | 1, 2, 3 |
| 5 | [Shaders and pipelines](05-shaders-pipelines-and-bindings.md) | MSL, metallib, pipeline state, bindings | 1, 2, 4 |
| 6 | [Metal-native features](06-metal-native-features.md) | Mesh, argument buffers, ICB, tile, ray tracing | 2–5 |
| 7 | [Renderer layer](07-renderer-layer.md) | Forward, Forward+, and GPU-driven rendering | 3–6 |
| 8 | [Scene and assets](08-scene-assets-and-built-in-shaders.md) | Geometry, materials, lights, built-in MSL | 4–7 |
| 9 | [Viewport and picking](09-viewport-and-picking.md) | Feature composition and editor behavior | 3, 4, 7, 8 |
| 10 | [Host integrations](10-host-integrations.md) | AppKit, MTKView, GUI, font, Python, interop | 1–9 as needed |
| 11 | [Validation and examples](11-validation-and-examples.md) | Consumer tests, examples, capability matrix | 1–10 |

The order is a default dependency order, not a requirement that every module
be completed before any prototype work begins. The first vertical slice is:

1. Build and C++ ABI.
2. Device and capabilities.
3. Commands and an offscreen surface.
4. A render pipeline using a planned mesh-shader example.
5. An external C++ consumer example.

## Module boundaries

### Core library

Plans 01–05 define the minimum installable Swift/Metal wrapper. They should
not depend on AppKit, MetalKit, ImGui, Assimp, or Python.

### Metal extension layer

Plan 06 contains features that are native to Metal or specific device
families. The extension layer must remain capability-gated but must not be
omitted from the public design.

### Rendering and domain layers

Plans 07–09 provide the higher-level behavior that corresponds to vkkk's
renderer, scene, and viewport layers. They consume the core API; they do not
own the host application's event loop or window.

### Optional adapters

Plan 10 contains integrations that can be built as separate targets. An
application using only offscreen rendering should not link these targets.

## Status convention

All plans begin as design work. When implementation starts, each plan should
track:

- `Status`: proposed, in progress, implemented, or blocked.
- Public headers and targets created.
- Tests and examples completed.
- Decisions that changed the parent plan.
- Follow-up work that was intentionally deferred.

