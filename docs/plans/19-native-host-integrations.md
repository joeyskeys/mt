# Plan 19 — Native host integrations

**Status:** proposed — optional integration
**Scope:** AppKit, `CAMetalLayer`, `MTKView`, GLFW, and Qt hosts
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 10, 12, 17, and the verification workflow from Plan 18

## Goal

Provide isolated host adapters and real windowed consumers without changing
the ownership model of the graphics wrapper. The core remains usable for
offscreen rendering and does not start an event loop or own a window.

## Integration work owned by this plan

- Runtime validation of the existing AppKit/`CAMetalLayer` and `MTKView`
  adapters, including Retina scale, drawable size, resize, unavailable
  drawables, presentation, and application-owned frame loops.
- C++/Swift generated-header installation and optional-framework isolation
  checks for the existing adapter targets.
- A native AppKit/CAMetalLayer window consumer and an `MTKView` consumer.
- Host-side translation of native pointer, button, scroll, key, resize, close,
  and focus events into `HostInputEvent`.
- Demand-driven GLFW and Qt adapters with the same borrowed-handle and
  application-owned-lifetime rules.

## Integration boundary

- AppKit, MetalKit, GLFW, and Qt are optional targets disabled by default.
- Host adapters configure borrowed native handles or view objects; they do
  not own the `Device`, `CommandQueue`, renderer, or application frame loop.
- Input translation produces toolkit-neutral values consumed by the viewport.
- Each adapter has its own generated header, framework linkage, example, and
  smoke test. The core package must remain buildable without these frameworks.

## Implementation steps

1. Specify target/handle ownership, thread, resize, scale, drawable-loss, and
   presentation contracts for each host.
2. Finish AppKit/CAMetalLayer and MTKView runtime behavior and examples.
3. Add native event translators and input/resize lifecycle tests.
4. Add GLFW and Qt only as separate targets when their consumer contract is
   known; do not add them as unconditional dependencies.
5. Verify installation and generated headers for every enabled adapter.

## Tests

- Optional C++ API-shape tests for every adapter.
- Windowed smoke tests for drawable acquisition, presentation, resize, Retina
  sizing, unavailable drawables, and shutdown.
- Input translation tests covering all toolkit-neutral event variants.
- Build-isolation tests proving the core target does not link AppKit,
  MetalKit, GLFW, or Qt unless explicitly enabled.

## Acceptance criteria

- A host application can run an application-owned frame loop with each
  enabled adapter and present a rendered frame.
- Resize and drawable loss are recoverable and observable.
- Optional host targets can be installed and consumed independently.
- An offscreen core consumer remains free of host-framework dependencies.

## Non-goals

- Adding renderer, scene, shader, or picking behavior; see Plans 13–17.
- ImGui, font, Python, asset-pipeline, or external-resource integrations;
  see Plans 20–22.
- A mandatory cross-platform window abstraction.
