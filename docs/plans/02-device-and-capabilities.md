# Plan 02 — Device, command queues, and capabilities

**Status:** implemented — Swift-first migration in progress; verification pending
**Parent:** [`METAL_WRAPPER_PLAN.md`](../../METAL_WRAPPER_PLAN.md)
**Dependencies:** [Plan 01](01-build-and-cpp-abi.md)

## Goal

Expose Metal's device and queue model as a small, explicit Swift API that
generates a C++ interface:

```text
mt::Device → mt::CommandQueue → mt::CommandBuffer
```

This module is the root of the runtime. It must not become a global context,
resource registry, renderer, or window manager.

## Responsibilities

- Select and retain an `MTLDevice`.
- Report device capabilities and limits.
- Create command queues.
- Provide factories for later resources and pipeline states.
- Expose optional native handles.
- Define device-loss, unsupported-feature, and creation-error behavior.
- Establish queue and device threading rules.

## Non-goals

- Command-buffer encoding; Plan 03 owns that.
- Resource descriptor details; Plan 04 owns those.
- Shader and pipeline layouts; Plan 05 owns those.
- Drawable acquisition; Plan 03 and Plan 10 own that.
- A singleton default device.

## Public API sketch

The following is the Swift source API. Swift/C++ interoperability generates
the C++ declarations consumed by applications:

```swift
public final class Device {
    public static func systemDefault() -> Device?
    public static func enumerate() -> [DeviceInfo]
    public static func fromRegistryID(_ id: UInt64) -> Device?

    public var info: DeviceInfo { get }
    public var capabilities: DeviceCapabilities { get }
    public func createCommandQueue(label: String) -> CommandQueue?
    public func nativeHandle() -> UnsafeMutableRawPointer
}

public final class CommandQueue {
    public func makeCommandBuffer() -> CommandBuffer?
    public var label: String { get set }
    public func nativeHandle() -> UnsafeMutableRawPointer
}
```

The C++ generated header maps Swift classes to reference-counted C++ wrapper
types and Swift optionals/arrays/strings to Swift interoperability support
types. Do not hand-write a second ownership implementation in C++.

`Device` and `CommandQueue` are Swift reference types. The generated C++
wrappers retain the Swift objects; applications must not copy raw native
handles or assume C++ value semantics.

Plan 02 provides the minimal `mt::CommandBuffer` wrapper needed for queue
creation, status inspection, labels, and native-handle access. Encoder
creation, presentation, completion callbacks, and commit behavior belong to
Plan 03.

## Capability model

Separate identity, limits, and optional features:

```swift
struct DeviceInfo {
    let name: String
    let registryID: UInt64
    let type: DeviceType
    let recommendedMaxWorkingSetSize: UInt64
}

struct DeviceCapabilities {
    let macFamily: MetalFamily
    let appleFamily: MetalFamily
    let argumentBufferTier: ArgumentBufferTier
    let unifiedMemory: Bool
    let indirectCommandBuffers: Bool
    let meshShaders: Bool
    let tileShaders: Bool
    let memorylessAttachments: Bool
    let rayTracing: Bool
    let dynamicLibraries: Bool
    let counterSampling: Bool

    let maxThreadsPerThreadgroup: UInt32
    let maxBufferLength: UInt64
    let maxArgumentBufferSamplerCount: UInt32
    let maxTextureDimension2D: UInt32
    let supportedSampleCounts: [UInt32]
}
```

The actual fields must correspond to runtime Metal queries and SDK availability.
Do not infer capabilities from the product name or from “Apple Silicon”
alone. A capability can depend on OS version, GPU family, and the requested
Metal API path.

Capabilities should support:

- `supports(feature)` queries for application decisions;
- `require(feature)` validation for fail-fast initialization;
- formatted diagnostics explaining missing capability and device details;
- limit queries used by pipeline and resource validation.

## Device selection

Support:

- system default device;
- explicit device selection using stable `DeviceInfo`;
- enumeration for applications that choose discrete versus integrated GPUs;
- an optional policy object for power/performance preference.

Do not hide device selection in a process-global singleton. Applications may
need more than one device or need to choose a device before constructing
renderers.

## Queue policy

Metal's queue model is simpler than Vulkan's family model. The wrapper should
not invent graphics/compute/transfer queue families. Instead:

- expose a normal command queue;
- allow multiple queues when the device and workload justify them;
- document ordering and synchronization between queues;
- keep queue creation independent from surfaces;
- avoid promising asynchronous behavior that Metal cannot guarantee.

The initial implementation can use one queue per application. Multiple queues
should be tested only after cross-queue synchronization is explicit.

## Native handle boundary

Provide a typed or tagged borrowed opaque pointer from Swift that can expose:

- the underlying `MTLDevice`;
- the underlying `MTLCommandQueue`;
- later command/resource objects.

The pointer must be documented as non-owning. Native access should not bypass
capability validation for wrapper-managed operations.

## Lifetime and threading

- A device outlives queues and resources created from it.
- A queue outlives command buffers created from it.
- Device queries are safe concurrently if the native API permits them.
- Queue creation and wrapper bookkeeping have documented synchronization.
- Command-buffer encoding rules are defined in Plan 03.
- No module stores mutable global device state.

## Error cases

At minimum, represent:

- no system default Metal device;
- requested device disappeared or became unusable;
- command queue creation failure;
- requested feature unsupported;
- limit too small for a descriptor;
- unavailable OS/API entry point.

Optional returns and status/value types should identify the failed operation
and feature/limit involved. Swift-only `Error` values must not leak into the
generated C++ API unless they are explicitly interop-compatible.

## Implementation steps

1. Add Swift `DeviceInfo`, `DeviceType`, `MetalFamily`, and
   `DeviceCapabilities`.
2. Implement Swift system-default device creation.
3. Implement Swift device enumeration and explicit selection.
4. Implement Swift command queue/command buffer creation and native handles.
5. Add runtime capability and limit queries through Metal.
6. Add Swift capability helpers and C++-visible diagnostics/status values.
7. Add Swift device/queue lifetime tests and generated-header compile tests.
8. Add an external C++ consumer example that prints device capabilities.

## Acceptance criteria

- A C++ consumer can enumerate devices and choose one.
- A selected device can create a command queue without a global context.
- Capabilities are queried at runtime and are not hard-coded to Apple Silicon.
- Unsupported mesh, tile, argument-buffer, ICB, or ray-tracing requests fail
  clearly.
- Native device and queue handles are available through the documented escape
  hatch.
- Device/queue ownership and thread rules are covered by tests or examples.

## Implementation in this slice

Implemented in Swift:

- `Device`, `CommandQueue`, and minimal `CommandBuffer` reference types;
- runtime device enumeration, system-default selection, and registry-ID
  selection;
- device identity, unified-memory classification, family detection, feature
  flags, and key limits;
- runtime capability queries for argument buffers, ICBs, mesh shaders, tile
  shaders, memoryless targets, ray tracing, dynamic libraries, counters, and
  supported sample counts;
- CMake Swift/C++ interoperability and generated-header integration;
- Swift-side capability tests and C++ header/consumer test targets.

Richer device-limit provenance and Metal-native capability completion belong
to [Plan 14 — Metal-native capabilities completion](14-metal-native-capabilities-completion.md).
Core ABI/package decisions belong to
[Plan 12 — Core ABI, resources, and lifetime completion](12-core-abi-resources-and-lifetime.md).
Build and runtime verification is intentionally pending on a Metal-capable
macOS machine; that evidence is tracked in
[Plan 18 — Validation, examples, and release evidence](18-validation-examples-and-release.md).

