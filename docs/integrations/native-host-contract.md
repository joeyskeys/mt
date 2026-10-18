# Native host contract

Plan 19 keeps host integration outside the graphics wrapper's core target.
`mt::mt` owns Metal objects and offscreen work; an optional host target only
translates a borrowed native view/layer into the core `Surface` contract.

## Ownership

- The application owns `Device`, `CommandQueue`, `CommandBuffer`, renderer,
  frame scheduling, and the event loop.
- `AppKitSurfaceAdapter` and `MTKViewSurfaceAdapter` retain the configured
  Metal surface and borrowed host bridge for as long as the adapter is alive.
- `AppKitWindowHost` and `MTKViewWindowHost` are example consumers. They own
  only their native window/view pair and adapter; they do not create queues or
  submit frames implicitly.
- `nativeViewHandle`, `nativeLayerHandle`, `windowHandle`, and `viewHandle`
  are borrowed opaque pointers. They are valid only while the corresponding
  host object/native object remains alive.

## Thread and frame rules

- AppKit, `MTKView`, resize, and input translation calls are main-thread-only.
- A host must acquire a drawable, create a render pass, encode work, end the
  encoder, present the drawable, and commit the application-owned command
  buffer.
- `nextDrawable()` may return `nil`. The host must treat that as a recoverable
  drawable-loss/back-pressure result and skip the frame.
- A resize invalidates the previous drawable-size assumption. The host must
  call `resizeToView()` or `syncDrawableSize()` before encoding the next
  frame.
- Presentation is explicit through `present(_:on:)`; adapters never commit or
  present on their own.

## Scale and size

AppKit view sizes are logical points. The adapter configures
`CAMetalLayer.drawableSize` in physical pixels and exposes `scaleFactor`.
`MTKView` keeps its drawable-size policy; the adapter exposes the current
physical `drawableSize` through the shared `Surface`.

## Input

`AppKitInputTranslator` converts borrowed `NSEvent`/`NSView` pointers into
`HostInputEvent` values. Pointer coordinates are view-local logical points
with a top-left origin. Resize, close, and focus notifications are translated
through explicit value constructors. No AppKit type crosses the core
`mt::mt` header boundary.

## Optional framework isolation

`MT_BUILD_APPKIT`, `MT_BUILD_MTKVIEW`, and `MT_BUILD_HOST_EXAMPLES` are opt-in.
The core target and its installed headers do not include AppKit or MetalKit.
The optional adapters install their own generated Swift headers and facade
headers only when enabled.

GLFW and Qt adapters remain demand-driven. There is no concrete consumer
contract in this repository that defines their native Metal layer ownership,
drawable acquisition, or package dependency. They must be added as separate
targets after such a contract is supplied; no unconditional GLFW or Qt
dependency is introduced here.
