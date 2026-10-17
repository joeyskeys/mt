# Plan 10 — Host, window, UI, font, and interop integrations

**Status:** implemented — optional AppKit/MetalKit and input slice; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** [Plan 01](01-build-and-cpp-abi.md), plus only the core modules required by each adapter

## Goal

Make the core Metal library usable from common macOS hosts without forcing
those hosts into the core dependency graph.

## Integration boundary

The core library consumes:

- a device;
- a drawable provider or offscreen target;
- size/resize notifications;
- optional input/events supplied by the host.

It does not create an application event loop, own an AppKit window, or require
Swift.

Adapters convert host objects to the core `Surface` and frame contracts. The
core already accepts a borrowed opaque `CAMetalLayer` handle; host adapters
remain responsible for creating/configuring that layer and managing the
application event loop.

## 1. AppKit and `CAMetalLayer`

### Scope

- Create/configure a `CAMetalLayer`.
- Wrap an opaque native layer handle as `mt::Surface`.
- Translate drawable size and scale factor.
- Handle layer resize and drawable availability.
- Present through the application-owned event loop.

### Boundary

Keep `CAMetalLayer`, `NSView`, and AppKit types out of core public C++ headers.
The core's opaque layer boundary does not require an AppKit dependency. Put
layer creation/configuration and AppKit view integration in an optional target:

```text
mt::mt-appkit
  Sources/MTAppKit/AppKitSurface.swift
```

If a public C++ header must expose a host surface, use a generated Swift
interop type or an opaque borrowed handle. Do not require an Objective-C++
factory.

### Acceptance

- An AppKit application can attach a layer-backed surface.
- Drawable size and resize are correct for Retina scale factors.
- No AppKit framework is required by offscreen consumers.

## 2. `MTKView`

Provide an optional adapter for applications that already use `MTKView`:

- use its device and drawable configuration;
- map its current drawable/render-pass descriptor;
- avoid making `MTKView` the core frame scheduler;
- support a direct delegate example only as convenience.

The adapter should not force `MetalKit` onto the base library or prevent
applications from using a custom `CAMetalLayer` path.

## 3. GLFW and Qt

Add only if required by actual consumers:

- GLFW native-view/layer extraction;
- Qt `QWindow`/`QMetalSurface` integration;
- resize, close, and drawable-size notifications;
- toolkit-specific build targets and dependency isolation.

Do not copy vkkk's Vulkan instance-extension contract. Metal surface creation
does not require Vulkan instance extension negotiation.

## 4. Input and window contract

If the viewport needs input, define a toolkit-neutral event type:

- pointer position and buttons;
- keyboard key/modifier state;
- scroll;
- resize;
- close/focus.

The host adapter translates events. The viewport consumes events but does not
poll AppKit or Qt directly.

## 5. ImGui

Add an optional `mt-imgui` target:

- initialize ImGui with application-owned context;
- use the Metal backend;
- share the application's device/queue and render target;
- provide begin-frame and render helpers;
- keep command-buffer and frame ownership explicit;
- support overlay load/store behavior.

Do not make ImGui types appear in the core renderer or viewport headers.

## 6. Font and text

Provide an optional font module:

- font loading;
- glyph atlas generation;
- text mesh or texture generation;
- Metal texture upload;
- billboard/overlay rendering;
- scale and color handling.

The module should expose text resources to the scene/viewport layer without
requiring the core library to depend on FreeType or CoreText. Separate
FreeType/CoreText adapters may be added later.

## 7. Python bindings

Only start after the C++ API is stable:

- bind value/descriptive types first;
- make device/resource lifetime explicit;
- avoid exposing native Objective-C objects;
- support offscreen rendering before window integration;
- keep the binding target optional.

The binding should consume the same installed C++ API as an external project.

## 8. External resource interop

Investigate Metal-supported interop only for a concrete use case:

- IOSurface-backed textures;
- shared events;
- host-provided buffers/textures;
- image or media pipeline integration.

Do not promise CUDA/Vulkan external-memory parity on macOS. Document device,
OS, ownership, synchronization, and pixel-format limitations for every
interop path.

## 9. Build isolation

Suggested target dependencies:

```text
mt::mt
  ├── mt::mt-appkit
  ├── mt::mt-mtkview
  ├── mt::mt-imgui
  ├── mt::mt-font
  └── mt::mt-python
```

Each optional target must:

- be disabled by default unless requested;
- expose only its own dependency headers;
- have an independent smoke test;
- preserve the core offscreen build when unavailable.

## Implementation steps

1. Implement the AppKit/`CAMetalLayer` adapter.
2. Add a small C++ AppKit consumer example once the core surface module exists.
3. Add the optional `MTKView` adapter.
4. Define toolkit-neutral input and resize events.
5. Add ImGui and font targets.
6. Add GLFW/Qt only when a host project requires them.
7. Add Python after the C++ ABI and resource lifetimes stabilize.
8. Add and test concrete external-resource interop.

## Acceptance criteria

- The core library builds without AppKit, MetalKit, ImGui, font, Python, or
  toolkit dependencies.
- A C++ AppKit application can render a drawable through `CAMetalLayer`.
- An `MTKView` consumer can use an optional adapter.
- UI/font integrations do not take ownership of the device or frame loop.
- Optional target failures do not break offscreen core builds.
- Every interop path documents ownership and synchronization.

## Implementation in this slice

The core remains free of AppKit, MetalKit, ImGui, font, Python, GLFW, and Qt
dependencies. Plan 10 adds two opt-in Swift targets:

```text
mt::mt
  ├── mt::mt-appkit   (MT_BUILD_APPKIT=ON)
  └── mt::mt-mtkview  (MT_BUILD_MTKVIEW=ON)
```

The corresponding SwiftPM products are `MTAppKit` and `MTMetalKit`; neither is
required when an application uses only `MTCore`.

`mt-appkit` provides `AppKitSurfaceConfiguration` and
`AppKitSurfaceAdapter`. The adapter accepts borrowed opaque `NSView` or
`CAMetalLayer` handles, configures the layer with an explicit `Device`,
pixel format, drawable size, Retina scale, framebuffer policy, transaction
mode, and display-sync policy, then delegates drawable/render-pass ownership
to the existing `Surface`. It exposes no AppKit or Objective-C protocol types
in the generated C++ API.

`mt-mtkview` provides `MTKViewSurfaceConfiguration` and
`MTKViewSurfaceAdapter`. It accepts a borrowed `MTKView` handle, applies the
device and drawable configuration, and maps its CAMetalLayer to the same
layer-backed `Surface` contract. The adapter does not create a queue, run a
delegate, present frames implicitly, or own the host event loop.

The core now also exposes `InputEventKind`, `InputModifiers`, and
`HostInputEvent` through `mt/input.hpp`. `Viewport.handleInput` consumes these
toolkit-neutral pointer, button, scroll, key, resize, close, and focus events;
AppKit or another host translates native events into this value contract.

Optional CMake targets are disabled by default and install their generated
Swift C++ headers and facade headers only when enabled. Optional C++ API-shape
tests are registered under `tests/unit/host`.

## Intentionally deferred

- A full AppKit `NSView` subclass or event-loop/delegate implementation
  belongs to
  [Plan 19 — Native host integrations](19-native-host-integrations.md).
- GLFW and Qt adapters belong to Plan 19 and remain demand-driven.
- ImGui initialization/render helpers and backend version management belong to
  [Plan 20 — GUI and text integrations](20-gui-and-text-integrations.md).
- CoreText/FreeType font loading, glyph atlases, and text mesh generation
  belong to Plan 20.
- Python bindings belong to
  [Plan 22 — Language and external-resource integrations](22-language-and-external-resource-integrations.md)
  and must consume the stabilized installed C++ API.
- IOSurface/media interop, shared-event policies for external producers, and
  imported texture ownership rules belong to Plan 22.
- Windowed examples and host runtime verification belong to Plans 19 and 18
  respectively.

Build, C++ ABI generation, and optional-framework verification remain pending
on a suitable macOS machine; the verification workflow is tracked in
[Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).

