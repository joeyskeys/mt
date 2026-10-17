# Plan 22 — Language and external-resource integrations

**Status:** proposed — optional integration
**Scope:** Python and IOSurface/media/external-texture interop
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** Plans 12, 18, and 19 where a host producer is involved

## Goal

Expose stable wrapper functionality to scripting and external producers only
after the C++ ABI, ownership, synchronization, and package contracts are
stable. These integrations must not weaken the core Metal API or make
external-resource frameworks mandatory.

## Integration work owned by this plan

- Python bindings for the stabilized C++ value and resource API.
- Python ownership, exception, threading, and lifetime policy.
- IOSurface-backed textures and buffers where Metal supports the required
  format and usage.
- Media/external-texture producers and consumers.
- Shared-event synchronization policy for external producers.
- Imported-resource ownership, release, format, cache-mode, and
  synchronization rules.
- Independent package targets, examples, and smoke tests.

## Integration boundary

- Python bindings consume the installed C++ API; they do not expose Swift
  implementation details or generate a second incompatible object model.
- External resources are borrowed/imported with explicit ownership and
  synchronization metadata. The wrapper must not assume it can destroy or
  mutate producer-owned storage.
- IOSurface, media, and shared events are optional capabilities with
  availability and format checks.
- Imported textures participate in Plan 12 lifetime and Plan 14 capability
  validation, but the core remains usable without them.

## Implementation steps

1. Freeze the C++ ABI/value ownership rules required by the binding layer.
2. Define Python handle, exception, GIL/threading, buffer, texture, and
  completion behavior.
3. Add IOSurface/imported-texture descriptors and borrowed/retained ownership
  contracts.
4. Add shared-event and producer/consumer synchronization policies.
5. Add media conversion/format validation adapters without assuming a
  particular media framework.
6. Add separate Python and external-resource examples and package tests.

## Tests

- Python import, handle lifetime, exception, threading, and readback tests.
- Imported-resource format/storage/usage rejection tests.
- Producer-owned and wrapper-owned release-order tests.
- Shared-event signal/wait and cross-queue synchronization tests.
- Build-isolation tests with Python, IOSurface, and media frameworks disabled.

## Acceptance criteria

- Python can use the stable installed C++ API without importing Swift source.
- External textures and buffers have explicit ownership, format, and
  synchronization behavior.
- Unsupported external-resource combinations fail before GPU submission.
- Core, host, and renderer consumers do not acquire a mandatory Python or
  media dependency.

## Non-goals

- Reopening the C++ ABI design for one scripting binding.
- Promising CUDA/Vulkan external-memory parity on macOS.
- Taking ownership of a producer's window, queue, event loop, or media graph.
