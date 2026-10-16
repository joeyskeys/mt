# Plan 03 — Command buffers, encoders, surfaces, and frames

**Status:** implemented — Swift-first implementation; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** [Plan 01](01-build-and-cpp-abi.md), [Plan 02](02-device-and-capabilities.md)

## Goal

Expose Metal's command submission model directly while providing enough
surface and frame convenience for windowed applications.

The low-level flow should remain recognizable to a Metal developer:

```text
surface drawable
    + command queue
    → command buffer
    → render/compute/blit encoder
    → end encoding
    → present if needed
    → commit
```

## Responsibilities

- `CommandBuffer` creation, encoder creation, commit, present, and completion.
- Render, compute, blit, and optional parallel-render encoders.
- Render-pass descriptors and explicit load/store/resolve actions.
- Offscreen surfaces and drawable-provider abstraction.
- `CAMetalLayer` adapter boundary.
- Optional `Frame` and `FrameScheduler`.
- Resize, drawable loss, frame pacing, and command-buffer errors.

## Non-goals

- Resource allocation and upload policy; Plan 04 owns that.
- Pipeline and binding creation; Plan 05 owns that.
- AppKit event handling; Plan 10 owns that.
- A Vulkan-style swapchain, command pool, or global context.

## Core command objects

### `CommandBuffer`

Wraps one `MTLCommandBuffer` and owns its encoding state:

- created from one `CommandQueue`;
- creates one or more encoder objects in valid Metal order;
- supports labels and debug groups;
- can register completion callbacks;
- can be committed once;
- reports status and execution errors.

The wrapper should make invalid state transitions difficult:

```text
created → encoding → committed → scheduled → completed/error
```

An encoder must be ended before another incompatible encoder is created or the
command buffer is committed. If the API permits multiple encoders, their
ordering must be explicit.

### Encoder types

Provide focused types:

- `RenderEncoder`: one render pass and graphics commands.
- `ComputeEncoder`: compute pipeline and dispatch commands.
- `BlitEncoder`: buffer/texture copies, clears, resolves, and mip generation.
- `ParallelRenderEncoder`: optional, only if multi-threaded render encoding is
  needed and correctly modeled.

Do not collapse all commands into one `CommandContext` abstraction that hides
Metal encoder boundaries.

## Command buffer API sketch

```cpp
class CommandBuffer {
public:
    Result<RenderEncoder> make_render_encoder(
        const RenderPassDesc& desc);
    Result<ComputeEncoder> make_compute_encoder();
    Result<BlitEncoder> make_blit_encoder();

    void present(const Drawable& drawable);
    void add_completion_handler(CompletionHandler handler);
    CommandBufferStatus status() const noexcept;
    std::optional<Error> error() const;
    void commit();

    NativeHandle native_handle() const noexcept;
};
```

`commit()` should return or record a clear error if called before required
encoders have ended. Whether commit is consuming or idempotent must be
documented.

The initial implementation treats `commit()` as consuming: a second call
returns `false`. The Swift/C++-interop surface uses `Bool` results for operations that
can fail, `errorDescription` for retained command-buffer/wrapper diagnostics,
and `waitUntilScheduled()`/`waitUntilCompleted()` for completion observation.
This keeps the generated API within the supported interop subset while the
resource and pipeline modules establish richer result types.

## Render-pass model

`RenderPassDesc` should describe Metal behavior, not Vulkan subpass behavior:

- color attachments and optional resolve targets;
- depth and stencil attachments;
- load action: load, clear, or dont-care;
- store action: store, dont-care, or resolve;
- clear values;
- sample count and attachment compatibility;
- optional tile shader/imageblock configuration;
- debug label.

The descriptor should not imply that a pass can contain nested subpasses.
Pass boundaries should correspond to encoder boundaries.

Attachment ownership is external: a render pass references textures or a
surface drawable; it does not own them.

## Surface model

Define a surface-independent provider:

```cpp
class Surface {
public:
    Extent drawable_size() const noexcept;
    PixelFormat color_format() const noexcept;
    Result<Drawable> next_drawable();
    Result<RenderPassDesc> make_render_pass(const Drawable&) const;
    void resize(Extent);
};
```

Required surface modes:

1. **Offscreen** — creates or references a texture target and is usable in
   tests, compute tools, and headless applications.
2. **Layer-backed** — receives an opaque `CAMetalLayer` handle through an
   AppKit/QuartzCore adapter.
3. **External target** — lets a host provide a texture or drawable-like target
   without making the core depend on a UI framework.

`Drawable` is transient. It represents the current drawable texture and its
presentation metadata. It must not be cached past the frame that acquired it.

## Frame convenience layer

The core does not require `begin_frame`/`end_frame`, but a scheduler may group
common operations:

```cpp
Result<Frame> FrameScheduler::begin_frame(
    Surface&, CommandQueue&);
Result<void> FrameScheduler::end_frame(Frame&);
```

`Frame` contains references to:

- the transient drawable, if any;
- the command buffer;
- the render-pass descriptor or target;
- frame index and drawable size;
- completion state.

It must not own the device, queue, resource cache, or renderer. A no-drawable
frame should be representable without treating it as device failure.

## Presentation and resize

- Acquire drawables only when a frame is ready to encode.
- Handle `nextDrawable` returning no drawable.
- Keep drawable size distinct from logical window size.
- Rebuild size-dependent render targets on resize.
- Present only after the final encoder using the drawable has ended.
- Support applications that do not present, such as offscreen tests.
- Make frame pacing policy optional.

Metal drawable acquisition is not Vulkan swapchain acquisition. The wrapper
must not expose image indices or semaphores unless they have a real Metal
meaning.

## Completion and errors

Completion handlers should report:

- command-buffer status;
- GPU execution errors;
- drawable/presentation status where available;
- frame identifier and debug label.

Errors should be retained long enough for applications to inspect them after
the command buffer has completed.

## Implementation steps

1. Add `CommandBuffer` state tracking over the native command buffer.
2. Add render, compute, and blit encoder wrappers.
3. Add labels, debug groups, commit, present, and completion handlers.
4. Implement an offscreen `Surface`.
5. Implement render-pass descriptors and attachment validation.
6. Add a layer-backed surface adapter interface without importing AppKit into
   core headers.
7. Add optional `Frame`/`FrameScheduler`.
8. Add a small C++ triangle consumer using direct command-buffer submission.
9. Add resize, no-drawable, completion-error, and offscreen tests.

## Acceptance criteria

- A consumer can create a command buffer without a global context.
- Render, compute, and blit encoders have distinct types and lifetimes.
- An offscreen render pass can be encoded, committed, and read back.
- A layer-backed drawable can be presented through an optional adapter.
- Render-pass load/store/resolve actions validate against attachment formats.
- Missing drawables and command-buffer failures are recoverable/reportable.
- The optional frame scheduler is implemented as convenience, not a core
  ownership layer.

## Implementation in this slice

Implemented in Swift:

- command-buffer state tracking, labels, debug groups, commit, presentation,
  completion-status polling, and completion-error capture;
- distinct render, compute, and blit encoder wrappers with explicit
  `endEncoding()` lifetimes;
- color render-pass descriptors with Metal load/store actions, clear values,
  sample-count reporting, resolve validation, and attachment format checks;
- offscreen surfaces, borrowed external-texture surfaces, and an opaque
  `CAMetalLayer` adapter boundary;
- transient drawables, resize handling, and optional `FrameScheduler`
  convenience for begin/end submission;
- C++ facade aliases and organized command/surface/frame headers;
- Swift runtime tests plus generated-header compile coverage for the new API.

Depth/stencil attachments and basic resource copy operations are provided by
Plan 04; drawable readback and full subresource operations remain deferred.
C++ callback registration remains represented by completion-status polling and
retained completion errors until a callback shape supported cleanly by
Swift/C++ interop is selected. Build and runtime verification remains
intentionally pending on a Metal-capable macOS machine. The triangle consumer
is likewise deferred until Plan 05 provides shader and pipeline APIs.

