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

| Order | Plan | Module | Scope | Depends on |
| --- | --- | --- | --- | --- |
| 0 | [Overview](00-overview.md) | Boundaries, conventions, and milestones | Architecture | — |
| 1 | [Build and C++ ABI](01-build-and-cpp-abi.md) | Swift target, generated header, and package | Wrapper | — |
| 2 | [Device and capabilities](02-device-and-capabilities.md) | Swift Metal objects exposed to C++ | Wrapper | 1 |
| 3 | [Commands and surfaces](03-commands-surfaces-and-frames.md) | Command buffers, encoders, drawables, frames | Wrapper | 1, 2 |
| 4 | [Resources and synchronization](04-resources-memory-and-sync.md) | Buffers, textures, heaps, uploads, hazards | Wrapper | 1, 2, 3 |
| 5 | [Shaders and pipelines](05-shaders-pipelines-and-bindings.md) | MSL, metallib, pipeline state, bindings | Wrapper | 1, 2, 4 |
| 6 | [Metal-native features](06-metal-native-features.md) | Mesh, argument buffers, ICB, tile, ray tracing | Wrapper | 2–5 |
| 7 | [Renderer layer](07-renderer-layer.md) | Forward, Forward+, and GPU-driven rendering | Wrapper | 3–6 |
| 8 | [Scene and assets](08-scene-assets-and-built-in-shaders.md) | Geometry, materials, lights, built-in MSL | Wrapper | 4–7 |
| 9 | [Viewport and picking](09-viewport-and-picking.md) | Feature composition and editor behavior | Wrapper | 3, 4, 7, 8 |
| 10 | [Host integrations](10-host-integrations.md) | AppKit, MTKView, GUI, font, Python, interop | Integration | 1–9 as needed |
| 11 | [Validation and examples](11-validation-and-examples.md) | Consumer tests, examples, capability matrix | Verification | 1–10 |
| 12 | [Core ABI, resources, and lifetime completion](12-core-abi-resources-and-lifetime.md) | Package, transfers, completion, retirement | Wrapper | 1–4 |
| 13 | [Shaders, pipelines, and bindings completion](13-shaders-pipelines-and-bindings-completion.md) | Caches, archives, layouts, argument tables | Wrapper | 5, 12 |
| 14 | [Metal-native capabilities completion](14-metal-native-capabilities-completion.md) | Tile, ray tracing, counters, limits | Wrapper | 2–6, 12, 13 |
| 15 | [Renderer completion](15-renderer-completion.md) | Clusters, passes, culling, native paths | Wrapper | 12–14, 16 |
| 16 | [Scene, assets, and built-in shaders completion](16-scene-assets-and-built-in-shaders-completion.md) | Mesh data, materials, scene sync, shader families | Wrapper | 12–14 |
| 17 | [Viewport and picking completion](17-viewport-and-picking-completion.md) | Feature drawing, ID passes, rich picking | Wrapper | 12–16 |
| 18 | [Validation, examples, and release evidence](18-validation-examples-and-release.md) | Runtime proof, matrix, CI, performance | Verification | 1–17 |
| 19 | [Native host integrations](19-native-host-integrations.md) | AppKit, MTKView, GLFW, Qt consumers | Integration | 10, 12, 17, 18 |
| 20 | [GUI and text integrations](20-gui-and-text-integrations.md) | ImGui, CoreText, FreeType, text assets | Integration | 13, 15, 17, 19 |
| 21 | [Asset-pipeline integrations](21-asset-pipeline-integrations.md) | Importers, codecs, conversion, serialization | Integration | 12, 16, 18 |
| 22 | [Language and external-resource integrations](22-language-and-external-resource-integrations.md) | Python, IOSurface, media, imported resources | Integration | 12, 18, 19 |

The numeric order groups related follow-up work. Plans 15 and 16 can be
developed in parallel after Plans 12–14; renderer completion consumes the
scene/material contracts as they stabilize. Plan 18 records evidence for the
wrapper plans, while Plans 19–22 remain optional consumers.

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

### Optional adapters and integrations

Plan 10 and Plans 19–22 contain integrations that can be built as separate
targets. An application using only offscreen rendering should not link these
targets.

## Follow-up scope categories

Plans 12–17 are still part of the graphics wrapper. They extend the
Swift-first Metal implementation and its generated C++ API, including
capability-specific Metal features. A feature being optional at runtime does
not make it an external integration.

Plan 18 is verification and release evidence. It proves the wrapper and its
packaging on Metal-capable machines but does not implement renderer or host
features. Its repository-side result schema, offscreen validation fixtures,
installed-consumer flow, example matrix, and Debug/Release/SwiftPM validation
automation are now present; device-specific evidence remains pending until a
Metal-capable verification run.

Plans 19–22 are optional integrations. They add host frameworks, GUI/text
libraries, content pipelines, scripting, or external-resource producers and
must remain independently enabled and tested.

Plan 19 now contains the Swift AppKit/CAMetalLayer and MTKView adapters,
borrowed-handle native window consumers, AppKit input translation, optional
host examples, and isolated host API tests. GLFW and Qt remain intentionally
demand-driven until a concrete native-layer ownership contract exists.

Plan 20 now contains isolated ImGui coordination, CoreText glyph/atlas/text
data, and a separate value-only FreeType bridge. These targets are opt-in and
do not alter the core `mt::mt` dependency graph.

Plan 21 now contains an isolated normalized asset-value boundary, deterministic
coordinate/material/texture conversion, a small P5/P6 fixture loader, and
versioned JSON serialization. It does not bundle Assimp, image codecs, or
other importer dependencies, and does not alter the core `mt::mt` dependency
graph.

Plan 22 is the final optional integration boundary. It contains the
dependency-isolated CPython facade and IOSurface imported-resource adapter.
Python is disabled by default and requires an explicitly selected interpreter
when its validation path is enabled; Conda and arbitrary user-selected
installations are supported through CMake cache variables. External textures
and buffers carry producer ownership, format/usage validation, and explicit
shared-event policies. Neither integration is included by `mt/mt.hpp`.

## Status convention

All plans begin as design work. When implementation starts, each plan should
track:

- `Status`: proposed, in progress, implemented, or blocked.
- Public headers and targets created.
- Tests and examples completed.
- Decisions that changed the parent plan.
- Follow-up work that was intentionally deferred.

