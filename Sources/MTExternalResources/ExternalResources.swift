import Foundation
import IOSurface
import Metal
import MTCore

public enum ExternalResourceOwnership: Int32, Codable, Equatable {
    case borrowed
    case retained
}

public enum ExternalResourceDiagnosticCode: Int32, Codable, Equatable {
    case none
    case invalidDescriptor
    case surfaceUnavailable
    case formatUnsupported
    case sizeMismatch
    case rangeInvalid
    case deviceMismatch
    case synchronizationRequired
    case importFailed
}

public struct ExternalResourceDiagnostic: Codable {
    public var code: ExternalResourceDiagnosticCode
    public var source: String
    public var field: String
    public var message: String

    public init(
        code: ExternalResourceDiagnosticCode,
        source: String,
        field: String,
        message: String
    ) {
        self.code = code
        self.source = source
        self.field = field
        self.message = message
    }
}

public struct IOSurfaceTextureDescriptor {
    public var surfaceID: UInt32
    public var width: UInt32
    public var height: UInt32
    public var pixelFormat: PixelFormat
    public var plane: UInt32
    public var usage: UInt32
    public var storageMode: StorageMode
    public var cpuCacheMode: CpuCacheMode
    public var ownership: ExternalResourceOwnership
    public var label: String

    public init(
        surfaceID: UInt32,
        width: UInt32,
        height: UInt32,
        pixelFormat: PixelFormat,
        plane: UInt32,
        usage: UInt32,
        ownership: ExternalResourceOwnership,
        label: String,
        storageMode: StorageMode = .shared,
        cpuCacheMode: CpuCacheMode = .defaultCache
    ) {
        self.surfaceID = surfaceID
        self.width = width
        self.height = height
        self.pixelFormat = pixelFormat
        self.plane = plane
        self.usage = usage
        self.storageMode = storageMode
        self.cpuCacheMode = cpuCacheMode
        self.ownership = ownership
        self.label = label
    }

    public var isValid: Bool {
        surfaceID > 0
            && width > 0
            && height > 0
            && pixelFormat.isIOSurfaceImportable
            && usage != 0
            && (usage & ~ExternalResourceUsage.textureMask) == 0
            && storageMode.supportsExternalIOSurfaceImport
    }
}

public struct IOSurfaceBufferDescriptor {
    public var surfaceID: UInt32
    public var offset: UInt64
    public var length: UInt64
    public var usage: UInt32
    public var storageMode: StorageMode
    public var cpuCacheMode: CpuCacheMode
    public var ownership: ExternalResourceOwnership
    public var label: String

    public init(
        surfaceID: UInt32,
        offset: UInt64,
        length: UInt64,
        usage: UInt32,
        ownership: ExternalResourceOwnership,
        label: String,
        storageMode: StorageMode = .shared,
        cpuCacheMode: CpuCacheMode = .defaultCache
    ) {
        self.surfaceID = surfaceID
        self.offset = offset
        self.length = length
        self.usage = usage
        self.storageMode = storageMode
        self.cpuCacheMode = cpuCacheMode
        self.ownership = ownership
        self.label = label
    }

    public var isValid: Bool {
        surfaceID > 0
            && length > 0
            && usage != 0
            && (usage & ~ExternalResourceUsage.bufferMask) == 0
            && storageMode.supportsExternalIOSurfaceImport
    }
}

public struct ExternalEventSyncPolicy: Codable, Equatable {
    public var waitValue: UInt64
    public var signalValue: UInt64
    public var waitBeforeEncoding: Bool
    public var signalAfterEncoding: Bool

    public init(
        waitValue: UInt64,
        signalValue: UInt64,
        waitBeforeEncoding: Bool,
        signalAfterEncoding: Bool
    ) {
        self.waitValue = waitValue
        self.signalValue = signalValue
        self.waitBeforeEncoding = waitBeforeEncoding
        self.signalAfterEncoding = signalAfterEncoding
    }

    public static var none: ExternalEventSyncPolicy {
        ExternalEventSyncPolicy(
            waitValue: 0,
            signalValue: 0,
            waitBeforeEncoding: false,
            signalAfterEncoding: false
        )
    }

    public var isValid: Bool {
        (!waitBeforeEncoding || waitValue > 0)
            && (!signalAfterEncoding || signalValue > 0)
    }
}

public struct ExternalTextureImportResult {
    public var resource: ImportedExternalTexture?
    public var diagnostics: [ExternalResourceDiagnostic]

    public init(
        resource: ImportedExternalTexture?,
        diagnostics: [ExternalResourceDiagnostic]
    ) {
        self.resource = resource
        self.diagnostics = diagnostics
    }

    public var succeeded: Bool {
        resource != nil && diagnostics.isEmpty
    }
}

public struct ExternalBufferImportResult {
    public var resource: ImportedExternalBuffer?
    public var diagnostics: [ExternalResourceDiagnostic]

    public init(
        resource: ImportedExternalBuffer?,
        diagnostics: [ExternalResourceDiagnostic]
    ) {
        self.resource = resource
        self.diagnostics = diagnostics
    }

    public var succeeded: Bool {
        resource != nil && diagnostics.isEmpty
    }
}

/// Retains the imported Metal texture and, when requested, an IOSurface use
/// count. The surface itself remains producer-owned.
public final class ImportedExternalTexture {
    public let texture: Texture
    public let descriptor: IOSurfaceTextureDescriptor
    private let retainedSurface: IOSurfaceRef?

    fileprivate init(
        texture: Texture,
        descriptor: IOSurfaceTextureDescriptor,
        surface: IOSurfaceRef?
    ) {
        self.texture = texture
        self.descriptor = descriptor
        if descriptor.ownership == .retained, let surface {
            IOSurfaceIncrementUseCount(surface)
            retainedSurface = surface
        } else {
            retainedSurface = nil
        }
    }

    deinit {
        if let retainedSurface {
            IOSurfaceDecrementUseCount(retainedSurface)
        }
    }
}

/// Retains the imported Metal buffer and, when requested, an IOSurface use
/// count. The surface itself remains producer-owned.
public final class ImportedExternalBuffer {
    public let buffer: Buffer
    public let descriptor: IOSurfaceBufferDescriptor
    private let retainedSurface: IOSurfaceRef?

    fileprivate init(
        buffer: Buffer,
        descriptor: IOSurfaceBufferDescriptor,
        surface: IOSurfaceRef?
    ) {
        self.buffer = buffer
        self.descriptor = descriptor
        if descriptor.ownership == .retained, let surface {
            IOSurfaceIncrementUseCount(surface)
            retainedSurface = surface
        } else {
            retainedSurface = nil
        }
    }

    deinit {
        if let retainedSurface {
            IOSurfaceDecrementUseCount(retainedSurface)
        }
    }
}

public final class IOSurfaceResourceImporter {
    public init() {}

    public func validate(
        _ descriptor: IOSurfaceTextureDescriptor
    ) -> [ExternalResourceDiagnostic] {
        guard descriptor.isValid else {
            return [
                diagnostic(
                    .invalidDescriptor,
                    source: "\(descriptor.surfaceID)",
                    field: "texture",
                    message: "The IOSurface texture descriptor is invalid."
                )
            ]
        }
        return []
    }

    public func validate(
        _ descriptor: IOSurfaceBufferDescriptor
    ) -> [ExternalResourceDiagnostic] {
        guard descriptor.isValid else {
            return [
                diagnostic(
                    .invalidDescriptor,
                    source: "\(descriptor.surfaceID)",
                    field: "buffer",
                    message: "The IOSurface buffer descriptor is invalid."
                )
            ]
        }
        return []
    }

    public func importTexture(
        device: Device,
        descriptor: IOSurfaceTextureDescriptor
    ) -> ExternalTextureImportResult {
        var diagnostics = validate(descriptor)
        guard diagnostics.isEmpty else {
            return ExternalTextureImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        guard let surface = IOSurfaceLookup(descriptor.surfaceID) else {
            diagnostics.append(
                diagnostic(
                    .surfaceUnavailable,
                    source: "\(descriptor.surfaceID)",
                    field: "surfaceID",
                    message: "The IOSurface could not be looked up."
                )
            )
            return ExternalTextureImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        guard IOSurfaceGetWidth(surface) == Int(descriptor.width),
              IOSurfaceGetHeight(surface) == Int(descriptor.height) else {
            diagnostics.append(
                diagnostic(
                    .sizeMismatch,
                    source: "\(descriptor.surfaceID)",
                    field: "size",
                    message: "The descriptor size does not match the IOSurface."
                )
            )
            return ExternalTextureImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        guard let metalDevice = metalDevice(from: device) else {
            diagnostics.append(
                diagnostic(
                    .deviceMismatch,
                    source: "\(descriptor.surfaceID)",
                    field: "device",
                    message: "The wrapper device could not be bridged to Metal."
                )
            )
            return ExternalTextureImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        guard let metalFormat = descriptor.pixelFormat.metalFormat else {
            diagnostics.append(
                diagnostic(
                    .formatUnsupported,
                    source: "\(descriptor.surfaceID)",
                    field: "pixelFormat",
                    message: "The pixel format cannot be imported from IOSurface."
                )
            )
            return ExternalTextureImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        let metalDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: metalFormat,
            width: Int(descriptor.width),
            height: Int(descriptor.height),
            mipmapped: false
        )
        metalDescriptor.usage = MTLTextureUsage(rawValue: UInt(descriptor.usage))
        metalDescriptor.storageMode = descriptor.storageMode.metalStorageMode
        metalDescriptor.cpuCacheMode = descriptor.cpuCacheMode.metalCacheMode
        guard let metalTexture = metalDevice.makeTexture(
            descriptor: metalDescriptor,
            iosurface: surface,
            plane: Int(descriptor.plane)
        ),
        let texture = device.wrapTexture(
            nativeHandle: Unmanaged.passUnretained(
                metalTexture as AnyObject
            ).toOpaque(),
            usage: descriptor.usage,
            label: descriptor.label
        ) else {
            diagnostics.append(
                diagnostic(
                    .importFailed,
                    source: "\(descriptor.surfaceID)",
                    field: "texture",
                    message: "Metal rejected the IOSurface texture import."
                )
            )
            return ExternalTextureImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        return ExternalTextureImportResult(
            resource: ImportedExternalTexture(
                texture: texture,
                descriptor: descriptor,
                surface: surface
            ),
            diagnostics: diagnostics
        )
    }

    public func importBuffer(
        device: Device,
        descriptor: IOSurfaceBufferDescriptor
    ) -> ExternalBufferImportResult {
        var diagnostics = validate(descriptor)
        guard diagnostics.isEmpty else {
            return ExternalBufferImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        guard let surface = IOSurfaceLookup(descriptor.surfaceID) else {
            diagnostics.append(
                diagnostic(
                    .surfaceUnavailable,
                    source: "\(descriptor.surfaceID)",
                    field: "surfaceID",
                    message: "The IOSurface could not be looked up."
                )
            )
            return ExternalBufferImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        let allocationSize = UInt64(IOSurfaceGetAllocSize(surface))
        guard descriptor.offset <= allocationSize,
              descriptor.length <= allocationSize - descriptor.offset,
              descriptor.offset <= UInt64(Int.max),
              descriptor.length <= UInt64(Int.max) else {
            diagnostics.append(
                diagnostic(
                    .rangeInvalid,
                    source: "\(descriptor.surfaceID)",
                    field: "range",
                    message: "The imported buffer range exceeds the IOSurface allocation."
                )
            )
            return ExternalBufferImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        guard let metalDevice = metalDevice(from: device) else {
            diagnostics.append(
                diagnostic(
                    .deviceMismatch,
                    source: "\(descriptor.surfaceID)",
                    field: "device",
                    message: "The wrapper device could not be bridged to Metal."
                )
            )
            return ExternalBufferImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        guard let baseAddress = IOSurfaceGetBaseAddress(surface) else {
            diagnostics.append(
                diagnostic(
                    .surfaceUnavailable,
                    source: "\(descriptor.surfaceID)",
                    field: "baseAddress",
                    message: "The IOSurface does not expose a CPU address."
                )
            )
            return ExternalBufferImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        var resourceOptions = descriptor.storageMode.metalResourceOptions
        resourceOptions.formUnion(descriptor.cpuCacheMode.metalResourceOptions)
        guard let metalBuffer = metalDevice.makeBuffer(
            bytesNoCopy: baseAddress.advanced(by: Int(descriptor.offset)),
            length: Int(descriptor.length),
            options: resourceOptions,
            deallocator: nil
        ),
        let buffer = device.wrapBuffer(
            nativeHandle: Unmanaged.passUnretained(
                metalBuffer as AnyObject
            ).toOpaque(),
            usage: descriptor.usage,
            label: descriptor.label
        ) else {
            diagnostics.append(
                diagnostic(
                    .importFailed,
                    source: "\(descriptor.surfaceID)",
                    field: "buffer",
                    message: "Metal rejected the IOSurface buffer import."
                )
            )
            return ExternalBufferImportResult(
                resource: nil,
                diagnostics: diagnostics
            )
        }
        return ExternalBufferImportResult(
            resource: ImportedExternalBuffer(
                buffer: buffer,
                descriptor: descriptor,
                surface: surface
            ),
            diagnostics: diagnostics
        )
    }
}

public final class ExternalSharedEventBridge {
    public let event: SharedEvent

    public init?(
        device: Device,
        label: String = ""
    ) {
        guard let event = device.createSharedEvent(label: label) else {
            return nil
        }
        self.event = event
    }

    public func applyWait(
        to commandBuffer: CommandBuffer,
        policy: ExternalEventSyncPolicy
    ) -> Bool {
        guard policy.isValid else {
            return false
        }
        guard policy.waitBeforeEncoding else {
            return true
        }
        return commandBuffer.waitFor(event, value: policy.waitValue)
    }

    public func applySignal(
        to commandBuffer: CommandBuffer,
        policy: ExternalEventSyncPolicy
    ) -> Bool {
        guard policy.isValid else {
            return false
        }
        guard policy.signalAfterEncoding else {
            return true
        }
        return commandBuffer.signal(event, value: policy.signalValue)
    }
}

private extension PixelFormat {
    var isIOSurfaceImportable: Bool {
        metalFormat != nil
    }

    var metalFormat: MTLPixelFormat? {
        switch self {
        case .r8Unorm:
            return .r8Unorm
        case .rgba8Unorm:
            return .rgba8Unorm
        case .bgra8Unorm:
            return .bgra8Unorm
        case .rgba16Float:
            return .rgba16Float
        default:
            return nil
        }
    }
}

private enum ExternalResourceUsage {
    static let textureMask: UInt32 =
        UInt32(TextureUsage.shaderRead.rawValue)
        | UInt32(TextureUsage.shaderWrite.rawValue)
        | UInt32(TextureUsage.shaderAtomic.rawValue)
        | UInt32(TextureUsage.renderTarget.rawValue)
        | UInt32(TextureUsage.pixelFormatView.rawValue)

    static let bufferMask: UInt32 =
        UInt32(BufferUsage.vertex.rawValue)
        | UInt32(BufferUsage.index.rawValue)
        | UInt32(BufferUsage.uniform.rawValue)
        | UInt32(BufferUsage.storage.rawValue)
        | UInt32(BufferUsage.indirect.rawValue)
        | UInt32(BufferUsage.readback.rawValue)
}

private extension StorageMode {
    var supportsExternalIOSurfaceImport: Bool {
        self == .shared || self == .managed
    }

    var metalStorageMode: MTLStorageMode {
        switch self {
        case .shared:
            return .shared
        case .managed:
            return .managed
        case .gpuPrivate:
            return .private
        case .memoryless:
            return .memoryless
        }
    }

    var metalResourceOptions: MTLResourceOptions {
        switch self {
        case .shared:
            return .storageModeShared
        case .managed:
            return .storageModeManaged
        case .gpuPrivate:
            return .storageModePrivate
        case .memoryless:
            return .storageModeMemoryless
        }
    }
}

private extension CpuCacheMode {
    var metalCacheMode: MTLCPUCacheMode {
        switch self {
        case .defaultCache:
            return .defaultCache
        case .writeCombined:
            return .writeCombined
        }
    }

    var metalResourceOptions: MTLResourceOptions {
        switch self {
        case .defaultCache:
            return .cpuCacheModeDefaultCache
        case .writeCombined:
            return .cpuCacheModeWriteCombined
        }
    }
}

private func metalDevice(from device: Device) -> MTLDevice? {
    let object = Unmanaged<AnyObject>
        .fromOpaque(device.nativeHandle())
        .takeUnretainedValue()
    return object as? MTLDevice
}

private func diagnostic(
    _ code: ExternalResourceDiagnosticCode,
    source: String,
    field: String,
    message: String
) -> ExternalResourceDiagnostic {
    ExternalResourceDiagnostic(
        code: code,
        source: source,
        field: field,
        message: message
    )
}
